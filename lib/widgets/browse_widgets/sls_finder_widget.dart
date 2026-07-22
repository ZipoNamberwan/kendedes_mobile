import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/area/sls.dart';

class SlsFinderWidget extends StatelessWidget {
	final bool isFindingSls;
	final bool isFindingSlsError;
	final String? slsFinderErrorMessage;
	final Sls? slsFinder;
	final VoidCallback onClose;

	const SlsFinderWidget({
		super.key,
		required this.isFindingSls,
		required this.isFindingSlsError,
		required this.slsFinderErrorMessage,
		required this.slsFinder,
		required this.onClose,
	});

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				if (isFindingSls)
					Container(
						width: double.infinity,
						padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
						decoration: BoxDecoration(
							color: Colors.blue.shade50.withValues(alpha: 0.95),
							borderRadius: BorderRadius.circular(16),
							border: Border.all(color: Colors.blue.shade200, width: 1),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.1),
									blurRadius: 8,
									offset: const Offset(0, 2),
								),
							],
						),
						child: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								SizedBox(
									width: 14,
									height: 14,
									child: CircularProgressIndicator(
										strokeWidth: 2,
										color: Colors.blue.shade700,
									),
								),
								const SizedBox(width: 8),
								Flexible(
									child: Text(
										'Mencari SLS pada titik ini...',
										style: TextStyle(
											color: Colors.blue.shade800,
											fontSize: 10,
											fontWeight: FontWeight.w600,
										),
									),
								),
							],
						),
					),
				if (isFindingSlsError)
					Container(
						width: double.infinity,
						margin: const EdgeInsets.only(top: 8),
						padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
						decoration: BoxDecoration(
							color: Colors.red.shade50.withValues(alpha: 0.95),
							borderRadius: BorderRadius.circular(16),
							border: Border.all(color: Colors.red.shade200, width: 1),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.1),
									blurRadius: 8,
									offset: const Offset(0, 2),
								),
							],
						),
						child: Row(
							children: [
								Expanded(
									child: Row(
										mainAxisSize: MainAxisSize.min,
										children: [
											Icon(
												Icons.error_outline_rounded,
												size: 14,
												color: Colors.red.shade700,
											),
											const SizedBox(width: 6),
											Flexible(
												child: Text(
													slsFinderErrorMessage?.trim().isNotEmpty == true
															? slsFinderErrorMessage!
															: 'SLS tidak ditemukan di titik ini',
													style: TextStyle(
														color: Colors.red.shade800,
														fontSize: 10,
														fontWeight: FontWeight.w500,
													),
												),
											),
										],
									),
								),
								SizedBox(
									width: 20,
									height: 20,
									child: InkWell(
										onTap: onClose,
										borderRadius: BorderRadius.circular(10),
										child: Icon(
											Icons.close,
											size: 14,
											color: Colors.red.shade700,
										),
									),
								),
							],
						),
					),
				if (slsFinder != null)
					Container(
						width: double.infinity,
						margin: const EdgeInsets.only(top: 8),
						padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
						decoration: BoxDecoration(
							color: Colors.green.shade50.withValues(alpha: 0.95),
							borderRadius: BorderRadius.circular(16),
							border: Border.all(color: Colors.green.shade200, width: 1),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.1),
									blurRadius: 8,
									offset: const Offset(0, 2),
								),
							],
						),
						child: Row(
							children: [
								Expanded(
									child: Text(
										'[${slsFinder!.longCode}] ${slsFinder!.name}, ${slsFinder!.village?.name ?? '-'}, ${slsFinder!.village?.subdistrict?.name ?? '-'}, ${slsFinder!.village?.subdistrict?.regency?.name ?? '-'}',
										style: TextStyle(
											color: Colors.green.shade800,
											fontSize: 10,
											fontWeight: FontWeight.w600,
										),
									),
								),
								SizedBox(
									width: 20,
									height: 20,
									child: InkWell(
										onTap: onClose,
										borderRadius: BorderRadius.circular(10),
										child: Icon(
											Icons.close,
											size: 14,
											color: Colors.green.shade700,
										),
									),
								),
							],
						),
					),
			],
		);
	}
}
