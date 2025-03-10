const std = @import("std");

const KV = struct {
    key: [2]u8,
    value: usize,
};

pub fn main() !void {
    const text = "The original BPE algorithm operates by iteratively replacing the most common contiguous sequences of characters in a target text with unused 'placeholder' bytes. The iteration ends when no sequences can be found, leaving the target text effectively compressed. Decompression can be performed by reversing this process, querying known placeholder terms against their corresponding denoted sequence, using a lookup table. In the original paper, this lookup table is encoded and stored alongside the compressed text.";

    var map = std.AutoHashMap([2]u8, usize).init(std.heap.page_allocator);
    defer map.deinit();

    for (text, 0..) |char, nextIdx| {
        if (nextIdx + 1 >= text.len) break;
        const key = [2]u8{ char, text[nextIdx + 1] };
        const gop = try map.getOrPut(key);

        if (gop.found_existing) {
            gop.value_ptr.* += 1;
        } else {
            gop.value_ptr.* = 1;
        }
    }

    var pairs = std.ArrayList(KV).init(std.heap.page_allocator);
    defer pairs.deinit();

    var iterator = map.iterator();
    while (iterator.next()) |item| {
        try pairs.append(KV{
            .key = item.key_ptr.*,
            .value = item.value_ptr.*,
        });
    }

    std.sort.heap(KV, pairs.items, {}, compByValueDesc);

    for (pairs.items) |pair| {
        std.debug.print("{c}{c} => {d}\n", .{
            pair.key[0],
            pair.key[1],
            pair.value,
        });
    }
}

fn compByValueDesc(_: void, a: KV, b: KV) bool {
    return a.value > b.value;
}
