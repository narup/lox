//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const Chunk = @import("chunk.zig").Chunk;
const Allocator = std.mem.Allocator;

pub fn prepare_lox(allocator: Allocator, stdout: anytype) !void {
    var chunk = try Chunk.init(allocator);
    defer chunk.deinit();

    try chunk.write_op(.op_add, 120);
    try chunk.write_constant(1.2, 120);
    try chunk.write_constant(45.69, 120);
    try chunk.write_constant(20, 123);
    try chunk.write_op(.op_return, 124);
    try chunk.write_constant(120.20, 124);

    try chunk.disassemble("test chunk", stdout);
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
