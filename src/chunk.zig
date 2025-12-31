const std = @import("std");
const Allocator = std.mem.Allocator;

const Value = f64;
pub const OpCode = enum(u8) { op_constant, op_return };

pub const Chunk = struct {
    codes: std.ArrayList(u8),
    constants: std.ArrayList(Value),
    allocator: Allocator,

    const Self = @This();

    pub fn init(allocator: Allocator) !Chunk {
        return .{
            .allocator = allocator,
            .codes = try std.ArrayList(u8).initCapacity(allocator, 100),
            .constants = try std.ArrayList(Value).initCapacity(allocator, 100),
        };
    }

    // Write an opcode
    pub fn write_op(self: *Self, op: OpCode) !void {
        try self.codes.append(self.allocator, @intFromEnum(op));
    }

    // Write a raw byte (for operands)
    pub fn write_byte(self: *Self, byte: u8) !void {
        try self.codes.append(self.allocator, byte);
    }

    // Add constant and return its index
    pub fn add_constant(self: *Self, value: Value) !u8 {
        try self.constants.append(self.allocator, value);
        return @intCast(self.constants.items.len - 1);
    }

    // Convenience: write OP_CONSTANT with its operand
    pub fn write_constant(self: *Self, value: Value) !void {
        const idx = try self.add_constant(value);
        try self.write_op(.op_constant);
        try self.write_byte(idx);
    }

    pub fn disassemble(self: Self, name: []const u8, writer: anytype) !void {
        try writer.print("==== {s} ====\n", .{name});

        var offset: usize = 0;
        while (offset < self.codes.items.len) {
            offset = try self.disassemble_instruction(offset, writer);
        }
    }

    fn disassemble_instruction(self: Self, offset: usize, writer: anytype) !usize {
        try writer.print("{d:0>4} ", .{offset});

        const instruction: OpCode = @enumFromInt(self.codes.items[offset]);
        switch (instruction) {
            .op_return => {
                try writer.print("OP_RETURN\n", .{});
                return offset + 1;
            },
            .op_constant => {
                const constant_idx = self.codes.items[offset + 1];
                const value = self.constants.items[constant_idx];
                try writer.print("OP_CONSTANT    {d} '{d}'\n", .{ constant_idx, value });
                return offset + 2;
            },
        }
    }

    pub fn deinit(self: *Self) void {
        self.codes.deinit(self.allocator);
        self.constants.deinit(self.allocator);
    }
};
