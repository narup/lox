const std = @import("std");
const Allocator = std.mem.Allocator;

const Value = f64;
pub const OpCode = enum(u8) { op_constant, op_add, op_return };

pub const Chunk = struct {
    code_block: std.ArrayList(u8),
    constant_block: std.ArrayList(Value),
    line_block: std.ArrayList(u8),
    allocator: Allocator,

    const Self = @This();

    pub fn init(allocator: Allocator) !Chunk {
        return .{
            .allocator = allocator,
            .code_block = try std.ArrayList(u8).initCapacity(allocator, 100),
            .constant_block = try std.ArrayList(Value).initCapacity(allocator, 100),
            .line_block = try std.ArrayList(u8).initCapacity(allocator, 100),
        };
    }

    // Write an opcode
    pub fn write_op(self: *Self, op: OpCode, line: u8) !void {
        try self.write_byte(@intFromEnum(op), line);
    }

    // Convenience: write OP_CONSTANT with its operand
    pub fn write_constant(self: *Self, value: Value, line: u8) !void {
        const idx = try self.add_constant(value);
        try self.write_op(.op_constant, line);
        try self.write_byte(idx, line);
    }

    // Write a raw byte (for operands)
    pub fn write_byte(self: *Self, byte: u8, line: u8) !void {
        try self.code_block.append(self.allocator, byte);
        try self.line_block.append(self.allocator, line);
    }

    pub fn disassemble(self: Self, name: []const u8, writer: anytype) !void {
        try writer.print("==== {s} ====\n", .{name});

        var offset: usize = 0;
        while (offset < self.code_block.items.len) {
            offset = try self.disassemble_instruction(offset, writer);
        }
    }

    // Add constant and return its index
    fn add_constant(self: *Self, value: Value) !u8 {
        try self.constant_block.append(self.allocator, value);
        return @intCast(self.constant_block.items.len - 1);
    }

    fn disassemble_instruction(self: Self, offset: usize, writer: anytype) !usize {
        try writer.print("{d:0>4} ", .{offset});
        if (offset > 0 and self.line_block.items[offset] == self.line_block.items[offset - 1]) {
            try writer.print("{s:4} ", .{"|"});
        } else {
            try writer.print("{d:>4} ", .{self.line_block.items[offset]});
        }

        const instruction: OpCode = @enumFromInt(self.code_block.items[offset]);
        switch (instruction) {
            .op_return => {
                try writer.print("{s:<16}\n", .{"OP_RETURN"});
                return offset + 1;
            },
            .op_add => {
                try writer.print("{s:<16}\n", .{"OP_ADD"});
                return offset + 1;
            },
            .op_constant => {
                const constant_idx = self.code_block.items[offset + 1];
                const value = self.constant_block.items[constant_idx];
                try writer.print("{s:<16} {d} '{d}'\n", .{ "OP_CONSTANT", constant_idx, value });
                return offset + 2;
            },
        }
    }

    pub fn deinit(self: *Self) void {
        self.code_block.deinit(self.allocator);
        self.constant_block.deinit(self.allocator);
        self.line_block.deinit(self.allocator);
    }
};
