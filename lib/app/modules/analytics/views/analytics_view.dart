import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:serv/app/global/widgets/loader.dart';
import '../../../widgets/common_bottom_navigation_bar.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AnalyticsController());
    
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
          'Analytics',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // Now using real API data since endpoints are ready
              controller.loadAnalyticsData();
              // Dummy data commented out since API is working
              // controller.loadDummyData();
            },
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFFFF6B35),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavigationBar(currentIndex: 4),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: LoaderCircle());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period selector
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.periods.length,
                  itemBuilder: (context, index) {
                    final period = controller.periods[index];
                    return Obx(() => GestureDetector(
                      onTap: () => controller.changePeriod(period),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: controller.selectedPeriod.value == period
                              ? const Color(0xFFFF6B35)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            color: controller.selectedPeriod.value == period
                                ? Colors.white
                                : const Color(0xFF6C757D),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ));
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildStatCard(
                      'Total Revenue',
                      '₹${controller.totalRevenue.value.toStringAsFixed(0)}',
                      Icons.currency_rupee,
                    )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => _buildStatCard(
                      'Total Orders',
                      '${controller.totalOrders.value}',
                      Icons.receipt_long,
                    )),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Obx(() => _buildStatCard(
                'Average Order Value',
                '₹${controller.averageOrderValue.value.toStringAsFixed(2)}',
                Icons.trending_up,
              )),
              
              const SizedBox(height: 20),
              
              // Orders served chart
              Obx(() => Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Orders Served',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Simple bar chart
                    SizedBox(
                      height: 200,
                      child: controller.ordersServedData.isEmpty
                          ? const Center(
                              child: Text(
                                'No data available',
                                style: TextStyle(
                                  color: Color(0xFF6C757D),
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: controller.ordersServedData.map((data) {
                                final maxValue = controller.ordersServedData
                                    .map((e) => e.orders)
                                    .reduce((a, b) => a > b ? a : b);
                                final height = maxValue > 0 ? (data.orders / maxValue) * 150 : 0.0;
                                
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${data.orders}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 30,
                                      height: height > 0 ? height : 5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF6B35),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data.day,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFF6B35),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }
}
