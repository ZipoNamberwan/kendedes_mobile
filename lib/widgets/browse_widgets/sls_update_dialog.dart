import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/browse/browse_bloc.dart';
import 'package:kendedes_mobile/bloc/browse/browse_state.dart';
import 'package:kendedes_mobile/models/sls_with_business.dart';

class SlsUpdateDialog extends StatelessWidget {
  final void Function(SlsWithBusiness item) onDownloadPressed;

  const SlsUpdateDialog({super.key, required this.onDownloadPressed});

  String _valueOrDash(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? '-' : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowseBloc, BrowseState>(
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade600,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.cloud_download_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Update Prelist SLS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${state.data.slsWithBusinessListForUpdate.length} SLS perlu diunduh ulang',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed:
                            state.data.updatingSlsWithBusinessId != null
                                ? null
                                : () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(
                            alpha:
                                state.data.updatingSlsWithBusinessId != null
                                    ? 0.4
                                    : 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error banner
                if (state.data.updatingSlsErrorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.data.updatingSlsErrorMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // List of SLS needing update
                Flexible(
                  child:
                      state.data.slsWithBusinessListForUpdate.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Tidak ada SLS yang perlu diperbarui.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                            itemCount:
                                state.data.slsWithBusinessListForUpdate.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item =
                                  state
                                      .data
                                      .slsWithBusinessListForUpdate[index];
                              final regencyName =
                                  item.sls.village?.subdistrict?.regency?.name;
                              final subdistrictName =
                                  item.sls.village?.subdistrict?.name;
                              final villageName = item.sls.village?.name;

                              final isDownloaded = state
                                  .data
                                  .updatedSlsWithBusinessId
                                  .contains(item.id);
                              final isDownloadingThis =
                                  state.data.updatingSlsWithBusinessId?.id ==
                                  item.id;
                              final isButtonDisabled =
                                  isDownloaded ||
                                  (state.data.updatingSlsWithBusinessId !=
                                          null &&
                                      !isDownloadingThis);

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _valueOrDash(item.sls.longCode),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.orange.shade800,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _valueOrDash(item.sls.name),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.business_outlined,
                                                size: 14,
                                                color: Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Jumlah usaha: ${item.businessCount}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${_valueOrDash(villageName)}, ${_valueOrDash(subdistrictName)}, ${_valueOrDash(regencyName)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _DownloadButton(
                                      isDownloaded: isDownloaded,
                                      isDownloading: isDownloadingThis,
                                      isDisabled: isButtonDisabled,
                                      onPressed: () => onDownloadPressed(item),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final bool isDownloaded;
  final bool isDownloading;
  final bool isDisabled;
  final VoidCallback onPressed;

  const _DownloadButton({
    required this.isDownloaded,
    required this.isDownloading,
    required this.isDisabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        isDownloaded
            ? Colors.green.shade50
            : (isDisabled ? Colors.grey.shade200 : Colors.deepOrange.shade50);
    final Color borderColor =
        isDownloaded
            ? Colors.green.shade300
            : (isDisabled ? Colors.grey.shade300 : Colors.deepOrange.shade200);
    final Color iconColor =
        isDownloaded
            ? Colors.green.shade600
            : (isDisabled ? Colors.grey.shade400 : Colors.deepOrange.shade600);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: (isDisabled || isDownloading) ? null : onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child:
              isDownloading
                  ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.deepOrange.shade600,
                    ),
                  )
                  : Icon(
                    isDownloaded ? Icons.check_rounded : Icons.download_rounded,
                    color: iconColor,
                    size: 20,
                  ),
        ),
      ),
    );
  }
}
