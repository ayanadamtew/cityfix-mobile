// lib/features/feed/screens/comment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_provider.dart';
import '../../../core/api_client.dart';

class CommentScreen extends ConsumerStatefulWidget {
  const CommentScreen({super.key, required this.issueId});

  final String issueId;

  @override
  ConsumerState<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final _commentCtrl = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      await ApiClient.instance.dio.post(
        '/api/issues/${widget.issueId}/comments',
        data: {'text': text},
      );
      _commentCtrl.clear();
      ref.invalidate(commentsProvider(widget.issueId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.issueId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: commentsAsync.when(
                data: (comments) {
                  if (comments.isEmpty) {
                    return const Center(child: Text('No comments yet. Be the first!'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: c.isAdmin ? 2 : 1,
                        color: c.isAdmin 
                            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5) 
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: c.isAdmin 
                              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1)
                              : BorderSide.none,
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    c.authorName, 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: c.isAdmin ? Theme.of(context).colorScheme.primary : null,
                                    )
                                  ),
                                  if (c.isAdmin) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.push_pin, size: 16, color: Theme.of(context).colorScheme.primary),
                                    if (c.adminRoleLabel != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          '- ${c.adminRoleLabel!}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                  ]
                                ],
                              ),
                              Text(
                                DateFormat.yMMMd().format(c.createdAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          subtitle: Text(
                            c.text,
                            style: TextStyle(
                              color: c.isAdmin ? Theme.of(context).colorScheme.onPrimaryContainer : null,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isPosting
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: _postComment,
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
