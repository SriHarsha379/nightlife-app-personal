// import 'package:flutter/material.dart';

// class HomeShimmer extends StatelessWidget {
//   final int selectedId;
//   final bool isDark;

//   const HomeShimmer({
//     super.key,
//     required this.selectedId,
//     required this.isDark,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final baseColor =
//         isDark ? Color.fromARGB(255, 83, 88, 95) : const Color(0xFFE7EBF1);
//     final highlightColor =
//         isDark ? Color.fromARGB(255, 90, 95, 100) : const Color(0xFFF6F8FB);

//     return Center(
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width * 0.9,
//         child: _ShimmerFrame(
//           baseColor: baseColor,
//           highlightColor: highlightColor,
//           child: _cardSkeleton(context, baseColor),
//         ),
//       ),
//     );
//   }

//   Widget _cardSkeleton(BuildContext context, Color baseColor) {
//     final size = MediaQuery.of(context).size;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // SizedBox(height: size.height * 0.01),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(22),
//           child: Container(
//             height: size.height * 0.43,
//             width: double.infinity,
//             color: baseColor,
//           ),
//         ),
//         SizedBox(height: size.height * 0.02),
//         // Row(
//         //   children: [
//         //     Container(
//         //       height: 14,
//         //       width: size.width * 0.35,
//         //       decoration: BoxDecoration(
//         //         color: baseColor,
//         //         borderRadius: BorderRadius.circular(10),
//         //       ),
//         //     ),
//         //     const Spacer(),
//         //     Container(
//         //       height: 30,
//         //       width: 30,
//         //       decoration: BoxDecoration(
//         //         color: baseColor,
//         //         shape: BoxShape.circle,
//         //       ),
//         //     ),
//         //   ],
//         // ),
//         // SizedBox(height: size.height * 0.015),
//         // _metaRow(size, baseColor),
//         // SizedBox(height: size.height * 0.01),
//         // _metaRow(size, baseColor, factor: 0.62),
//       ],
//     );
//   }

//   Widget _metaRow(Size size, Color baseColor, {double factor = 0.72}) {
//     final chipCount = selectedId == 1 ? 3 : 2;
//     return Row(
//       children: List.generate(chipCount, (index) {
//         return Container(
//           margin: const EdgeInsets.only(right: 8),
//           height: 24,
//           width: size.width * (factor / chipCount) * 0.9,
//           decoration: BoxDecoration(
//             color: baseColor,
//             borderRadius: BorderRadius.circular(20),
//           ),
//         );
//       }),
//     );
//   }
// }

// class _ShimmerFrame extends StatefulWidget {
//   final Widget child;
//   final Color baseColor;
//   final Color highlightColor;

//   const _ShimmerFrame({
//     required this.child,
//     required this.baseColor,
//     required this.highlightColor,
//   });

//   @override
//   State<_ShimmerFrame> createState() => _ShimmerFrameState();
// }

// class _ShimmerFrameState extends State<_ShimmerFrame>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1300),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       child: widget.child,
//       builder: (context, child) {
//         final dx = -1 + (_controller.value * 2);
//         return ShaderMask(
//           blendMode: BlendMode.srcATop,
//           shaderCallback: (rect) {
//             return LinearGradient(
//               begin: Alignment(dx - 1, -0.25),
//               end: Alignment(dx + 1, 0.25),
//               colors: [
//                 widget.baseColor,
//                 widget.highlightColor,
//                 widget.baseColor,
//               ],
//               stops: const [0.25, 0.5, 0.75],
//             ).createShader(rect);
//           },
//           child: child,
//         );
//       },
//     );
//   }
// }
