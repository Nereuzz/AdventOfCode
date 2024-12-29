const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input.txt");
const strToInt = std.fmt.parseInt;

const Cpu = struct { A: i64, B: i64, C: i64, PC: u64 = 0 };
const Instruction = enum { adv, bxl, bst, jnz, bxc, out, bdv, cdv };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var lines = std.mem.splitSequence(u8, input, "\n\n");
    var registerLines = std.mem.splitAny(u8, lines.next().?, ":\n");

    _ = registerLines.next();
    const a = try strToInt(i64, trimSpaces(registerLines.next().?), 10);
    _ = registerLines.next();
    const b = try strToInt(i64, trimSpaces(registerLines.next().?), 10);
    _ = registerLines.next();
    const c = try strToInt(i64, trimSpaces(registerLines.next().?), 10);

    var program = std.ArrayList(u8).init(allocator);
    defer program.deinit();
    var progIter = std.mem.splitScalar(u8, std.mem.trim(u8, lines.next().?, "Program: \n"), ',');
    while (progIter.next()) |opcode| {
        try program.append(try std.fmt.parseInt(u3, opcode, 10));
    }

    var cpu: Cpu = .{ .A = a, .B = b, .C = c };
    const sol1 = try p1(&cpu, program.items, allocator, true);
    defer allocator.free(sol1);

    // cpu = .{ .A = 0, .B = b, .C = c };
    const sol2 = try p2(program.items, allocator);

    print("Day 17\nPart 1: {s}\nPart 2: {}\n", .{ sol1, sol2 });
}

fn p2(program: []u8, allocator: std.mem.Allocator) !u64 {
    var a: i64 = 0;
    var revP: [16]u8 = undefined;
    std.mem.copyBackwards(u8, &revP, program);
    for (revP, 0..) |c, i| {
        revP[i] = std.fmt.digitToChar(c, .lower);
    }

    for (0..program.len) |i| {
        a = a << 3;
        var found = false;
        while (!found) {
            var cpu: Cpu = .{ .A = a, .B = 0, .C = 0 };
            const tmp = try p1(&cpu, program, allocator, false);
            defer allocator.free(tmp);

            if (!std.mem.eql(u8, tmp, revP[revP.len - 1 - i ..])) {
                a += 1;
            } else {
                found = true;
            }
        }
    }
    return @intCast(a);
}

fn p1(cpu: *Cpu, program: []const u8, allocator: std.mem.Allocator, addComma: bool) ![]u8 {
    var result = try std.BoundedArray(u8, 25).init(0);
    while (true) {
        const opcode = program[cpu.PC];
        const operand = program[cpu.PC + 1];
        const instruction: Instruction = @enumFromInt(opcode);
        if (execute(cpu, instruction, operand)) |out| {
            const hest: u8 = @intCast(out);
            try result.append(std.fmt.digitToChar(hest, .lower));
            if (addComma) try result.append(',');
        }

        if (cpu.PC == program.len) break;
    }
    if (addComma) _ = result.pop();
    return allocator.dupe(u8, result.slice());
}

fn execute(cpu: *Cpu, instruction: Instruction, operand: u8) ?i64 {
    switch (instruction) {
        Instruction.adv => {
            const numerator = cpu.A;
            const comboOperand = GetComboOperand(cpu, operand);
            cpu.A = @divTrunc(numerator, std.math.pow(i64, 2, comboOperand));
            cpu.PC += 2;
        },
        Instruction.bdv => {
            const numerator = cpu.A;
            const comboOperand = GetComboOperand(cpu, operand);
            cpu.B = @divTrunc(numerator, std.math.pow(i64, 2, comboOperand));
            cpu.PC += 2;
        },
        Instruction.bst => {
            const combo = GetComboOperand(cpu, operand);
            const result = @mod(combo, 8) & 0b111;
            cpu.B = result;
            cpu.PC += 2;
        },
        Instruction.bxc => {
            cpu.B = cpu.B ^ cpu.C;
            cpu.PC += 2;
        },
        Instruction.bxl => {
            cpu.B = cpu.B ^ operand;
            cpu.PC += 2;
        },
        Instruction.cdv => {
            const numerator = cpu.A;
            const comboOperand = GetComboOperand(cpu, operand);
            cpu.C = @divTrunc(numerator, std.math.pow(i64, 2, comboOperand));
            cpu.PC += 2;
        },
        Instruction.out => {
            const combo = GetComboOperand(cpu, operand);
            cpu.PC += 2;
            return @mod(combo, 8);
        },
        Instruction.jnz => {
            switch (cpu.A) {
                0 => cpu.PC += 2,
                else => cpu.PC = operand,
            }
        },
    }
    return null;
}

fn GetComboOperand(cpu: *Cpu, operand: u8) i64 {
    if (operand < 4) return operand;
    return switch (operand) {
        // 1...3 => operand,
        4 => cpu.A,
        5 => cpu.B,
        6 => cpu.C,
        else => unreachable,
    };
}

fn trimSpaces(str: []const u8) []const u8 {
    return std.mem.trim(u8, str, " ");
}
