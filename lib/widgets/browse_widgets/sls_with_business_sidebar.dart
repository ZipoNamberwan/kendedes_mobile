import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/sls_with_business.dart';

class SlsWithBusinessSidebar extends StatelessWidget {
  final List<SlsWithBusiness> items;
  final void Function(SlsWithBusiness item) onDeleteTap;
  final bool isOpen;
  final VoidCallback onClose;
  final String title;

  const SlsWithBusinessSidebar({
    super.key,
    required this.items,
    required this.onDeleteTap,
    required this.isOpen,
    required this.onClose,
    this.title = 'Prelist SLS yang Sudah Diunduh',
  });

  String _valueOrDash(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? '-' : trimmed;
  }

  Widget _buildCountBadge(BuildContext context, int businessCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Text(
        '$businessCount usaha',
        style: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildRowItem(BuildContext context, SlsWithBusiness item) {
    final regencyName = item.sls.village?.subdistrict?.regency?.name;
    final subdistrictName = item.sls.village?.subdistrict?.name;
    final villageName = item.sls.village?.name;
    final slsName = item.sls.name;
    final slsLongCode = item.sls.longCode;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _valueOrDash(slsName),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.tag, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _valueOrDash(slsLongCode),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildCountBadge(context, item.businessCount),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_valueOrDash(regencyName)}, ${_valueOrDash(subdistrictName)}, ${_valueOrDash(villageName)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 40,
                height: 40,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onDeleteTap(item),
                    child: Center(
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      top: 0,
      right: isOpen ? 0 : -320,
      bottom: 0,
      width: 320,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 10,
                left: 16,
                right: 8,
              ),
              decoration: const BoxDecoration(color: Colors.blue),
              child: Row(
                children: [
                  const Icon(
                    Icons.download_done_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$title (${items.length})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onClose,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: 'Tutup',
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child:
                            items.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.download_done_rounded,
                                          size: 44,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Belum ada area terunduh',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Unduh prelist by SLS untuk melihat daftar',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  padding: const EdgeInsets.all(10),
                                  itemCount: items.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return _buildRowItem(context, item);
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
