import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/table_model.dart';
import '../../data/services/bill_service.dart';
import '../../core/controllers/global_data_controller.dart';

class SwitchTableModal extends StatefulWidget {
  final int currentTableId;
  final String currentTableName;
  final List<TableModel> availableTables;
  final Function(TableModel) onTableSwitched;

  const SwitchTableModal({
    super.key,
    required this.currentTableId,
    required this.currentTableName,
    required this.availableTables,
    required this.onTableSwitched,
  });

  @override
  State<SwitchTableModal> createState() => _SwitchTableModalState();
}

class _SwitchTableModalState extends State<SwitchTableModal> {
  TableModel? selectedTable;
  bool isLoading = false;
  final BillService _billService = Get.find<BillService>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Color(0xFFFF6B35),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Switch Table',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'From: ${widget.currentTableName}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Table Selection
            Expanded(
              child: widget.availableTables.isEmpty
                  ? _buildEmptyState()
                  : _buildTableGrid(),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading || selectedTable == null ? null : _performTableSwitch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Switch Table',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Available Tables',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All tables are currently occupied',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Reduced from 4 to 3 for more space
        childAspectRatio: 0.85, // Slightly taller for better text fit
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: widget.availableTables.length,
      itemBuilder: (context, index) {
        final table = widget.availableTables[index];
        final isSelected = selectedTable?.tableId == table.tableId;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedTable = table;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.table_restaurant,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 28,
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    table.tableName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    'Available',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : Colors.grey[500],
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performTableSwitch() async {
    if (selectedTable == null) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _billService.switchTable(
        oldTableId: widget.currentTableId,
        newTableId: selectedTable!.tableId,
      );

      if (result['success'] == true) {
        Get.back(); // Close modal
        Get.snackbar(
          'Success',
          result['message'] ?? 'Table switched successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        
        // Refresh tables globally after successful switch
        try {
          GlobalDataController.instance.notifyTableUpdate();
          print('🔄 Refreshing tables after switch');
        } catch (e) {
          print('🚨 Global controller not found: $e');
        }
        
        // Call the callback with the new table
        widget.onTableSwitched(selectedTable!);
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to switch table',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
