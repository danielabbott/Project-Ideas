// ** this code doesn't actually do anything, just brainstorming **

const std = @import("std");
const BoundedArray = std.BoundedArray;
const EnumMap = std.EnumMap;
const hasFn = std.meta.trait.hasFn;
const builtin = @import("builtin");

pub const Schema = struct {
    tables: []const type,
    indexes: []const TableColumn,
    foreign_keys: []const ForeignKey,
};

pub const TableColumn = struct {
    table: type,
    field: []const u8,
};

pub const ForeignKey = struct {
    pkey: TableColumn,
    fkey: TableColumn,
};

pub fn Selector(comptime KeyType: type) type {
    return struct {
        field_name: []const u8,
        op: enum { eql, greater_than, less_than },
        comparison_value: KeyType,
    };
}

// Temporary in-memory tables
fn TransactionRow(comptime Row: anytype) type {
    _ = Row;
    return struct {
        pk_id: u32, // fields would be added at compile time (search Row for pk_* fields)
        field_id: u32,
        state: enum { nulled, non_null, deleted },
        new_value: []const u8,
    };
}

pub fn DataBase(comptime schema: []const type) type {
    _ = schema;

    return struct {
        const Self = @This();

        pub fn load(file_path: []const u8, schema_version: u32) !Self {
            _ = file_path;
            _ = schema_version;
            // open database file, check schema version, check schema matches database, etc.
            return Self{};
        }

        pub fn getOne(self: *Self, comptime RowType: type, field_name: []const u8, comptime value: anytype) !RowType {
            _ = self;
            _ = field_name;
            _ = value;
            var row: RowType = undefined;
            // full table scan for matching row
            if (builtin.mode == .Debug and hasFn("validate")(RowType)) {
                try row.validate();
            }
            return row;
        }

        pub fn getMany(self: *Self, comptime RowType: type, selector: anytype) ![]RowType {
            _ = self;
            _ = RowType;
            _ = selector;
            return undefined;
        }

        pub fn insert(self: *Self, comptime RowType: type, row: RowType) !void {
            _ = self;

            if (hasFn("validate")(RowType)) {
                try row.validate();
            }
        }

        pub fn insertAutoInc(self: *Self, comptime RowType: type, auto_inc_field: []const u8, row: RowType) !void {
            _ = self;
            _ = RowType;
            _ = auto_inc_field;
            _ = row;
        }

        pub fn update(self: *Self, comptime RowType: type, row: RowType, field_names: []const []const u8) !void {
            _ = self;
            _ = RowType;
            _ = row;
            _ = field_names;
        }

        pub fn delete(self: *Self, comptime RowType: type, field_name: []const u8, comptime value: anytype) !void {
            _ = self;
            _ = RowType;
            _ = field_name;
            _ = value;
        }

        pub fn commit(self: *Self) !void {
            _ = self;
            // write current in-memory transaction to disk
        }

        pub fn deinit(self: *Self) !void {
            try self.commit();
            // close file etc.
        }
    };
}

/////

const my_schema = [_]type{ Sim, Clothing };

const SimAge = enum { baby, toddler, child, teenager, adult, elder };

const SimNameType = BoundedArray(u8, 24);

const Sim = struct {
    // pk_* fields are primary keys
    pk_id: u32,
    first_name: SimNameType,
    last_name: SimNameType,
    genetics: [16]u8,
    age: SimAge,

    clothes: union(enum) {
        full_body_outfit: u32, // fkey
        top_bottom_outfit: struct {
            top: u32, // fkey
            bottom: u32, // fkey
        },
    },

    // Row structs can have a validate() function which is called when inserting and updating
    pub fn validate(self: Sim) !void {
        if (self.first_name.len == 0 or self.last_name.len == 0) {
            return error.InvalidName;
        }
    }
};

const Clothing = struct {
    pk_id: u32,
    name: BoundedArray(u8, 32),
    asset_name: BoundedArray(u8, 32),
    valid_ages: EnumMap(SimAge, void),
};

test "" {
    var db = try DataBase(my_schema[0..]).load("mydatabase", 3);
    defer db.deinit() catch unreachable;

    var my_sim = Sim{
        .pk_id = 6,
        .first_name = SimNameType.fromSlice("John") catch unreachable,
        .last_name = SimNameType.fromSlice("Doe") catch unreachable,
        .genetics = [_]u8{0} ** 16,
        .age = .adult,
        .clothes = .{ .full_body_outfit = 0 },
    };

    try db.insert(Sim, my_sim);
    try db.insertAutoInc(Sim, "pk_id", my_sim); // id set to autoincrement value

    my_sim = try db.getOne(Sim, "pk_id", 5);
    my_sim.first_name = SimNameType.fromSlice("Susan") catch unreachable;
    try db.update(Sim, my_sim, ([_][]const u8{"first_name"})[0..]); // update specific field(s)

    try db.delete(Sim, "pk_id", 6);

    try db.commit();
}
