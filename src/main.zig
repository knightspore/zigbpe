const std = @import("std");

const KV = struct {
    key: [2]u8,
    value: usize,
};

pub fn main() !void {
    const text = "The original BPE algorithm operates by iteratively replacing the most common contiguous sequences of characters in a target text with unused 'placeholder' bytes. The iteration ends when no sequences can be found, leaving the target text effectively compressed. Decompression can be performed by reversing this process, querying known placeholder terms against their corresponding denoted sequence, using a lookup table. In the original paper, this lookup table is encoded and stored alongside the compressed text.";

    var map = std.AutoHashMap([2]u8, usize).init(std.heap.page_allocator);
    defer map.deinit();

    for (text, 1..) |char, nextIdx| {
        if (nextIdx == text.len) break;
        const key = [2]u8{ char, text[nextIdx] };
        const gop = try map.getOrPut(key);

        if (gop.found_existing) {
            gop.value_ptr.* += 1;
        } else {
            gop.value_ptr.* = 1;
        }
    }

    var iterator = map.iterator();

    while (iterator.next()) |item| {
        std.debug.print("[{c}{c}] : {d}\n", .{
            item.key_ptr.*[0],
            item.key_ptr.*[1],
            item.value_ptr.*,
        });
    }
}
