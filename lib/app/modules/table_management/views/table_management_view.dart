import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/common_bottom_navigation_bar.dart';
import '../controllers/table_management_controller.dart';
import '../../../data/models/table_model.dart';

class TableManagementView extends GetView<TableManagementController> {
  const TableManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
        ),
        title: const Text(
          'Table Management',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.refreshTables(),
            icon: const Icon(Icons.refresh, color: Color(0xFF2D3142)),
          ),
        ],
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage tables assigned to you',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab bar
            Obx(() => Row(
              children: [
                _buildTab('All Tables', 0),
                const SizedBox(width: 16),
                _buildTab('Available', 1),
                const SizedBox(width: 16),
                _buildTab('Occupied', 2),
              ],
            )),
            
            const SizedBox(height: 24),
            
            // Tables content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.tables.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B35),
                    ),
                  );
                }
                
                if (controller.hasError.value && controller.tables.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Color(0xFFFF6B35),
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF6C757D),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => controller.loadTables(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, 
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (controller.tables.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tables available',
                      style: TextStyle(
                        color: Color(0xFF6C757D),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: [
                    // Table grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: controller.tables.length,
                        itemBuilder: (context, index) {
                          final table = controller.tables[index];
                          return _buildTableItem(table);
                        },
                      ),
                    ),
                    
                    // Load more button
                    
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonBottomNavigationBar(
        currentIndex: 1, // Tables tab
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = controller.selectedTab.value == index;
    
    return GestureDetector(
      onTap: () => controller.selectTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          title,
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTableItem(TableModel table) {
    // status=true means Available (खाली), status=false means Occupied (भरा हुआ)
    final isOccupied = !table.status;
    final isSelected = table.isSelected;
    
    return GestureDetector(
      onTap: () => controller.toggleTableSelection(table),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFFF6B35) 
                : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Table number
                Flexible(
                  child: Text(
                    table.tableName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                ),
                
                // Selection indicator
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFFFF6B35),
                    size: 20,
                  ),
              ],
            ),
            
            const Spacer(),
            
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isOccupied 
                  ? const Color(0xFFFF6B35).withOpacity(0.1)
                  : const Color(0xFF28A745).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isOccupied ? 'Occupied' : 'Available',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOccupied 
                    ? const Color(0xFFFF6B35)
                    : const Color(0xFF28A745),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Room type
            
          ],
        ),
      ),
    );
  }
}
