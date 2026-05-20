// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

// class HomeScreenShimmer extends StatelessWidget {
//   const HomeScreenShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Container(
//       width: size.width,
//       height: size.height,
//       color: Colors.grey[50],
//       child: SingleChildScrollView(
//         physics: const NeverScrollableScrollPhysics(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: size.height * 0.01),
//             SizedBox(height: size.height * 0.01),

//             // Main content
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header Row Shimmer
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Hello text
//                       Shimmer.fromColors(
//                         baseColor: Colors.grey[300]!,
//                         highlightColor: Colors.grey[100]!,
//                         child: Container(
//                           width: size.width * 0.3,
//                           height: 20,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                         ),
//                       ),

//                       // Icons
//                       Row(
//                         children: [
//                           Shimmer.fromColors(
//                             baseColor: Colors.grey[300]!,
//                             highlightColor: Colors.grey[100]!,
//                             child: Container(
//                               width: size.width * 0.1,
//                               height: size.width * 0.1,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: size.width * 0.03),
//                           Shimmer.fromColors(
//                             baseColor: Colors.grey[300]!,
//                             highlightColor: Colors.grey[100]!,
//                             child: Container(
//                               width: size.width * 0.05,
//                               height: size.width * 0.05,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: size.height * 0.04),

//                   // Search Field Shimmer
//                   Shimmer.fromColors(
//                     baseColor: Colors.grey[300]!,
//                     highlightColor: Colors.grey[100]!,
//                     child: Container(
//                       width: double.infinity,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: size.height * 0.04),

//                   // Services Text Shimmer
//                   Shimmer.fromColors(
//                     baseColor: Colors.grey[300]!,
//                     highlightColor: Colors.grey[100]!,
//                     child: Container(
//                       width: size.width * 0.3,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: size.height * 0.02),

//                   // Services Grid Shimmer
//                   Wrap(
//                     spacing: size.width * 0.06,
//                     runSpacing: size.width * 0.06,
//                     children: List.generate(8, (index) {
//                       return Shimmer.fromColors(
//                         baseColor: Colors.grey[300]!,
//                         highlightColor: Colors.grey[100]!,
//                         child: Column(
//                           children: [
//                             Container(
//                               padding: EdgeInsets.all(size.width * 0.05),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: SizedBox(
//                                 width: size.width * 0.08,
//                                 height: size.width * 0.08,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(height: size.height * 0.014),
//                             Container(
//                               width: size.width * 0.15,
//                               height: 12,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }),
//                   ),

//                   SizedBox(height: size.height * 0.05),

//                   // Banner Shimmer
//                   Shimmer.fromColors(
//                     baseColor: Colors.grey[300]!,
//                     highlightColor: Colors.grey[100]!,
//                     child: Container(
//                       width: size.width * 0.9,
//                       height: size.height * 0.2,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: size.height * 0.02),

//                   // Banner Indicators Shimmer
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: List.generate(
//                       3,
//                       (index) => Container(
//                         width: 7,
//                         height: 7,
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                       ),
//                     ),
//                   ),

//                   SizedBox(height: size.height * 0.04),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ManageAddressShimmer extends StatelessWidget {
//   const ManageAddressShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           width: size.width,
//           height: size.height,
//           color: Colors.grey[50],
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: size.height * 0.01),

//               // Remove Expanded and use Flexible or remove scroll view
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
//                   child: Column(
//                     children: [
//                       SizedBox(height: size.height * 0.04),

//                       // Address list shimmer - Use Expanded for the list to take available space
//                       Expanded(
//                         child: ListView.separated(
//                           itemCount: 4, // Show 4 shimmer items
//                           shrinkWrap: false,
//                           physics: const NeverScrollableScrollPhysics(),
//                           separatorBuilder: (context, index) =>
//                               SizedBox(height: size.height * 0.02),
//                           itemBuilder: (context, index) {
//                             return Shimmer.fromColors(
//                               baseColor: Colors.grey[300]!,
//                               highlightColor: Colors.grey[100]!,
//                               child: Container(
//                                 padding: EdgeInsets.all(size.width * 0.05),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey[300]!),
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Colors.white,
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     // Icon
//                                     Container(
//                                       width: size.width * 0.06,
//                                       height: size.width * 0.06,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(6),
//                                       ),
//                                     ),

//                                     SizedBox(width: size.width * 0.04),

//                                     // Address details
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           // Tag
//                                           Container(
//                                             width: size.width * 0.2,
//                                             height: 14,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                             ),
//                                           ),

//                                           SizedBox(height: size.height * 0.005),

//                                           // Address line 1
//                                           Container(
//                                             width: double.infinity,
//                                             height: 12,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                             ),
//                                           ),

//                                           SizedBox(height: size.height * 0.005),

//                                           // Address line 2
//                                           Container(
//                                             width: size.width * 0.7,
//                                             height: 12,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                             ),
//                                           ),

//                                           SizedBox(height: size.height * 0.005),

//                                           // Landmark
//                                           Container(
//                                             width: size.width * 0.5,
//                                             height: 12,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(4),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),

//                                     // Edit icon
//                                     Container(
//                                       padding:
//                                           EdgeInsets.all(size.width * 0.02),
//                                       child: Container(
//                                         width: size.width * 0.05,
//                                         height: size.width * 0.05,
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius:
//                                               BorderRadius.circular(4),
//                                         ),
//                                       ),
//                                     ),

//                                     SizedBox(width: size.width * 0.02),

//                                     // Checkbox
//                                     Container(
//                                       width: size.width * 0.05,
//                                       height: size.width * 0.05,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ElectricalShimmer extends StatelessWidget {
//   const ElectricalShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: SafeArea(
//         child: Container(
//           width: size.width,
//           height: size.height,
//           color: Colors.grey[50],
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // SizedBox(height: size.height * 0.02),

//               // Grid with individual shimmer effects
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
//                   child: SingleChildScrollView(
//                     physics: const NeverScrollableScrollPhysics(),
//                     child: Wrap(
//                       spacing: size.width * 0.03,
//                       runSpacing: size.width * 0.07,
//                       children: List.generate(
//                         8,
//                         (index) => Shimmer.fromColors(
//                           baseColor: Colors.grey[300]!,
//                           highlightColor: Colors.grey[100]!,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.all(size.width * 0.02),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(8),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey.withOpacity(0.3),
//                                       offset: const Offset(0, 2),
//                                       blurRadius: 5,
//                                     )
//                                   ],
//                                 ),
//                                 child: Container(
//                                   width: size.width * 0.165,
//                                   height: size.width * 0.165,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.014),
//                               Container(
//                                 width: size.width * 0.2,
//                                 height: 10,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: size.height * 0.04),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ElectricalItemShimmer extends StatelessWidget {
//   const ElectricalItemShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: SafeArea(
//         child: Container(
//           width: size.width,
//           height: size.height,
//           color: Colors.grey[50],
//           child: Column(
//             children: [
//               // Content Shimmer
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
//                   child: Shimmer.fromColors(
//                     baseColor: Colors.grey[300]!,
//                     highlightColor: Colors.grey[100]!,
//                     child: ListView.separated(
//                       itemCount: 4, // Show 4 shimmer items
//                       separatorBuilder: (context, index) =>
//                           SizedBox(height: size.height * 0.02),
//                       itemBuilder: (context, index) {
//                         return Container(
//                           width: size.width * 0.9,
//                           padding: EdgeInsets.symmetric(
//                             horizontal: size.width * 0.03,
//                             vertical: size.height * 0.03,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.10),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               // Image Container Shimmer
//                               Container(
//                                 padding: EdgeInsets.all(size.width * 0.02),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(10),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey.withOpacity(0.3),
//                                       offset: const Offset(0, 2),
//                                       blurRadius: 5,
//                                     )
//                                   ],
//                                 ),
//                                 child: Container(
//                                   width: size.width * 0.15,
//                                   height: size.width * 0.15,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(width: size.width * 0.04),

//                               // Service Details Shimmer
//                               Expanded(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // Title
//                                     Container(
//                                       width: size.width * 0.5,
//                                       height: 16,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                     SizedBox(height: size.height * 0.01),
//                                     // Price
//                                     Container(
//                                       width: size.width * 0.3,
//                                       height: 18,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                     SizedBox(height: size.height * 0.015),
//                                     // Add Button/Quantity Controls Shimmer
//                                     Align(
//                                       alignment: Alignment.centerRight,
//                                       child: Container(
//                                         width: size.width * 0.24,
//                                         height: size.height * 0.04,
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius:
//                                               BorderRadius.circular(20),
//                                           border: Border.all(
//                                             color: Colors.grey[300]!,
//                                             width: 1,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ),

//               // Bottom Cart Section Shimmer
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: size.width * 0.05,
//                   vertical: size.height * 0.02,
//                 ),
//                 child: Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Container(
//                     width: size.width * 0.9,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: size.width * 0.04,
//                       vertical: size.height * 0.02,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               width: size.width * 0.2,
//                               height: 16,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                             SizedBox(height: size.height * 0.005),
//                             Container(
//                               width: size.width * 0.15,
//                               height: 12,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Container(
//                           width: size.width * 0.3,
//                           height: size.height * 0.045,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: size.height * 0.02),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CartShimmer extends StatelessWidget {
//   const CartShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Container(
//           width: size.width,
//           height: size.height,
//           // color: Colors.white,
//           child: Center(
//             child: SizedBox(
//               child: Column(
//                 children: [
//                   // Header Shimmer

//                   Expanded(
//                     child: Shimmer.fromColors(
//                       baseColor: Colors.grey[300]!,
//                       highlightColor: Colors.grey[100]!,
//                       child: SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             // Service Header Shimmer
//                             Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       width: size.width * 0.4,
//                                       height: 18,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: size.height * 0.03),
//                               ],
//                             ),

//                             // Cart Items List Shimmer
//                             Column(
//                               children: List.generate(3, (index) {
//                                 return Padding(
//                                   padding: EdgeInsets.only(
//                                       bottom: size.height * 0.03),
//                                   child: Container(
//                                     width: size.width * 0.9,
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: size.width * 0.03,
//                                       vertical: size.height * 0.02,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(16),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.10),
//                                           blurRadius: 6,
//                                           offset: const Offset(0, 4),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         // Service Image Shimmer
//                                         Container(
//                                           padding:
//                                               EdgeInsets.all(size.width * 0.02),
//                                           child: Container(
//                                             width: size.width * 0.15,
//                                             height: size.width * 0.15,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(width: size.width * 0.04),

//                                         // Service Details Shimmer
//                                         Expanded(
//                                           child: Column(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               // Title
//                                               Container(
//                                                 width: size.width * 0.5,
//                                                 height: 16,
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.white,
//                                                   borderRadius:
//                                                       BorderRadius.circular(4),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                   height: size.height * 0.005),
//                                               // Price
//                                               Container(
//                                                 width: size.width * 0.3,
//                                                 height: 18,
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.white,
//                                                   borderRadius:
//                                                       BorderRadius.circular(4),
//                                                 ),
//                                               ),
//                                               SizedBox(
//                                                   height: size.height * 0.02),

//                                               // Quantity Controls Shimmer
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.end,
//                                                 children: [
//                                                   Row(
//                                                     mainAxisSize:
//                                                         MainAxisSize.min,
//                                                     children: [
//                                                       // Add Button
//                                                       Container(
//                                                         width:
//                                                             size.width * 0.08,
//                                                         height:
//                                                             size.width * 0.08,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           shape:
//                                                               BoxShape.circle,
//                                                           color: Colors.white,
//                                                           border: Border.all(
//                                                             color: Colors
//                                                                 .grey[300]!,
//                                                             width: 1.5,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       // Quantity Display
//                                                       Container(
//                                                         width:
//                                                             size.width * 0.08,
//                                                         alignment:
//                                                             Alignment.center,
//                                                         child: Container(
//                                                           width: 20,
//                                                           height: 16,
//                                                           decoration:
//                                                               BoxDecoration(
//                                                             color: Colors.white,
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         4),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       // Remove Button
//                                                       Container(
//                                                         width:
//                                                             size.width * 0.08,
//                                                         height:
//                                                             size.width * 0.08,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           shape:
//                                                               BoxShape.circle,
//                                                           color: Colors.white,
//                                                           border: Border.all(
//                                                             color: Colors
//                                                                 .grey[300]!,
//                                                             width: 1.5,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }),
//                             ),

//                             SizedBox(height: size.height * 0.04),

//                             // Payment Summary Shimmer
//                             Column(
//                               children: [
//                                 // Payment Summary Title
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       width: size.width * 0.4,
//                                       height: 18,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: size.height * 0.02),

//                                 // Service Charge
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       width: size.width * 0.3,
//                                       height: 14,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                     Container(
//                                       width: size.width * 0.15,
//                                       height: 14,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: size.height * 0.02),

//                                 // Convenience Charge
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       width: size.width * 0.35,
//                                       height: 14,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                     Container(
//                                       width: size.width * 0.15,
//                                       height: 14,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: size.height * 0.02),

//                                 // Divider
//                                 Container(
//                                   height: size.width * 0.002,
//                                   color: Colors.grey[300],
//                                 ),
//                                 SizedBox(height: size.height * 0.02),

//                                 // Total Amount
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       width: size.width * 0.25,
//                                       height: 16,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                     Container(
//                                       width: size.width * 0.15,
//                                       height: 16,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.circular(4),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: size.height * 0.02),

//                                 // Divider
//                                 Container(
//                                   height: size.width * 0.002,
//                                   color: Colors.grey[300],
//                                 ),
//                               ],
//                             ),

//                             SizedBox(height: size.height * 0.05),

//                             // Checkout Button Shimmer
//                             Container(
//                               width: size.width * 0.9,
//                               height: size.height * 0.06,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(25),
//                               ),
//                             ),

//                             SizedBox(height: size.height * 0.05),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
