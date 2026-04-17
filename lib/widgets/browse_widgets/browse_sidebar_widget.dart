import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kendedes_mobile/bloc/browse/browse_bloc.dart';
import 'package:kendedes_mobile/bloc/browse/browse_event.dart';
import 'package:kendedes_mobile/bloc/browse/browse_state.dart';
import 'package:flutter/material.dart';

class BrowseSidebarWidget extends StatefulWidget {
  const BrowseSidebarWidget({super.key});

  @override
  State<BrowseSidebarWidget> createState() => _BrowseSidebarWidgetState();
}

class _BrowseSidebarWidgetState extends State<BrowseSidebarWidget> {
  late BrowseBloc _browseBloc;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _browseBloc = context.read<BrowseBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrowseBloc, BrowseState>(
      listener: (context, state) {
        if (state is BrowseSideBarOpened) {
          _searchController.text = '';
        } else if (state is BrowseSideBarClosed) {
          _searchFocusNode.unfocus();
        }
      },
      builder: (context, state) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          top: 0,
          right: state.data.isBrowseSideBarOpen ? 0 : -300,
          bottom: 0,
          width: 300,
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
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    bottom: 10,
                    left: 20,
                    right: 10,
                  ),
                  decoration: BoxDecoration(color: Colors.orange),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cari dan Filter Usaha',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed:
                            () => _browseBloc.add(SetBrowseSideBarOpen(false)),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
