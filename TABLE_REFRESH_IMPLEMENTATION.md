## Table Refresh Test Scenarios

### ✅ Automatic Table Refresh Implementation

1. **Order Placed (KOT Sent)** → `order_summary_controller.dart:88`
   - After successful KOT API call
   - `GlobalDataController.instance.notifyTableUpdate()`
   - Home screen tables automatically refresh

2. **Table Switch** → `switch_table_modal.dart:283`
   - After successful table switch API call  
   - `GlobalDataController.instance.notifyTableUpdate()`
   - Home screen tables automatically refresh

3. **Menu Screen Entry** → `menu_controller.dart:31`
   - When user enters menu with a table
   - `GlobalDataController.instance.notifyTableUpdate()` 
   - Marks table as occupied/in-use

4. **Home Screen Listener** → `home_controller.dart:32`
   - Listens for `GlobalDataController.instance.tableDataUpdated`
   - Automatically calls `loadTables()` when triggered

### Test Cases:

1. **Select available table** → Should show as occupied after menu entry
2. **Place order** → Table status should refresh without manual refresh
3. **Switch table** → Both old and new table status should update
4. **Multiple operations** → All should work without manual refresh

### Expected Behavior:
- ❌ **Before**: User had to press refresh button to see table updates
- ✅ **After**: Tables automatically refresh after any operation

All refresh operations now happen automatically through the GlobalDataController.
