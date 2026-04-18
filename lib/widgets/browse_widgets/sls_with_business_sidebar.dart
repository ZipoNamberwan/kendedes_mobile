import 'package:flutter/material.dart';
import 'package:kendedes_mobile/models/sls_with_business.dart';

class SlsWithBusinessSidebar extends StatefulWidget {
  final List<SlsWithBusiness> items;
  final void Function(SlsWithBusiness item) onDeleteTap;
  final void Function(SlsWithBusiness item) onItemTap;
  final void Function(String value) onSearch;
  final VoidCallback onClear;
  final bool isOpen;
  final VoidCallback onClose;
  final String title;

  const SlsWithBusinessSidebar({
    super.key,
    required this.items,
    required this.onDeleteTap,
    required this.onSearch,
    required this.onItemTap,
    required this.onClear,
    required this.isOpen,
    required this.onClose,
    this.title = 'Prelist SLS yang Sudah Diunduh',
  });

  @override
  State<SlsWithBusinessSidebar> createState() => _SlsWithBusinessSidebarState();
}

class _SlsWithBusinessSidebarState extends State<SlsWithBusinessSidebar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _valueOrDash(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? '-' : trimmed;
  }

  Widget _buildCountBadge(BuildContext context, int businessCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Text(
        '$businessCount usaha',
        style: TextStyle(
          color: Colors.blue.shade800,
          fontSize: 11,
          fontWeight: FontWeight.w700,
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
    final hasPolygon = item.sls.polygon != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: hasPolygon ? () => widget.onItemTap(item) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _valueOrDash(slsName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _valueOrDash(slsLongCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_valueOrDash(regencyName)}, ${_valueOrDash(subdistrictName)}, ${_valueOrDash(villageName)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildCountBadge(context, item.businessCount),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasPolygon) ...[
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 2),
                  ],
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => widget.onDeleteTap(item),
                        child: Center(
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      top: 0,
      right: widget.isOpen ? 0 : -320,
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
                      '${widget.title} (${widget.items.length})',
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
                    onPressed: widget.onClose,
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

            // Search box
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  widget.onSearch(value);
                },
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Cari SLS...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              widget.onClear();
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Colors.grey.shade500,
                            ),
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  isDense: true,
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Container(
                  decoration: BoxDecoration(
                    // color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child:
                      widget.items.isEmpty
                          ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.download_done_rounded,
                                    size: 44,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Belum ada Prelist SLS diunduh',
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
                            padding: const EdgeInsets.all(8),
                            itemCount: widget.items.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final item = widget.items[index];
                              return _buildRowItem(context, item);
                            },
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
