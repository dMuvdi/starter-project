import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/user_article.dart';
import '../bloc/article_editor/article_editor_cubit.dart';
import '../bloc/article_editor/article_editor_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart' as auth;

class ArticleEditorPage extends StatefulWidget {
  final UserArticleEntity? article;

  const ArticleEditorPage({Key? key, this.article}) : super(key: key);

  @override
  State<ArticleEditorPage> createState() => _ArticleEditorPageState();
}

class _ArticleEditorPageState extends State<ArticleEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ArticleEditorCubit>();

    if (widget.article != null) {
      cubit.initWithArticle(widget.article!);
      _titleController.text = widget.article!.title ?? '';
      _contentController.text = widget.article!.content ?? '';
    } else {
      cubit.initNewArticle();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticleEditorCubit, ArticleEditorState>(
      listener: (context, state) {
        if (state.status == ArticleEditorStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          context.read<ArticleEditorCubit>().clearError();
        }

        if (state.status == ArticleEditorStatus.success &&
            state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          if (!state.isDraft) {
            // If published, go back
            Navigator.pop(context, true);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ArticleEditorState state) {
    final isLoading = state.status == ArticleEditorStatus.saving ||
        state.status == ArticleEditorStatus.publishing ||
        state.status == ArticleEditorStatus.uploading;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black),
        onPressed: () => _onClose(context, state),
      ),
      title: Text(
        state.isDraft ? 'Draft' : 'Edit Article',
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => _saveDraft(context),
          child: Text(
            'Save Draft',
            style: TextStyle(
              color: isLoading ? Colors.grey : const Color(0xFF3B5BDB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _publish(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B5BDB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Publish',
                    style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ArticleEditorState state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoverImageSection(context, state),
                const SizedBox(height: 24),
                _buildTitleField(context),
                const SizedBox(height: 16),
                _buildContentField(context),
              ],
            ),
          ),
        ),
        _buildBottomBar(context, state),
      ],
    );
  }

  Widget _buildCoverImageSection(
      BuildContext context, ArticleEditorState state) {
    final hasImage =
        state.coverImageUrl != null || state.localImagePath != null;

    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: state.localImagePath != null
                        ? Image.file(
                            File(state.localImagePath!),
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            state.coverImageUrl!,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => _pickImage(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  if (state.status == ArticleEditorStatus.uploading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B5BDB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Color(0xFF3B5BDB),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Add Cover Image',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Optimal size 1200 × 630px',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return TextField(
      controller: _titleController,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
      decoration: const InputDecoration(
        hintText: 'Article Title',
        hintStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black26,
        ),
        border: InputBorder.none,
      ),
      maxLines: null,
      onChanged: (value) {
        context.read<ArticleEditorCubit>().updateTitle(value);
      },
    );
  }

  Widget _buildContentField(BuildContext context) {
    return TextField(
      controller: _contentController,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
        color: Colors.black54,
      ),
      decoration: InputDecoration(
        hintText: 'Start writing your story...',
        hintStyle: TextStyle(
          fontSize: 16,
          color: Colors.grey[400],
        ),
        border: InputBorder.none,
      ),
      maxLines: null,
      minLines: 10,
      onChanged: (value) {
        context.read<ArticleEditorCubit>().updateContent(value);
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, ArticleEditorState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tags section
          if (state.categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.categories.map((category) {
                  return Chip(
                    label: Text('#$category'),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      context
                          .read<ArticleEditorCubit>()
                          .removeCategory(category);
                    },
                    backgroundColor: Colors.grey[100],
                    labelStyle:
                        TextStyle(color: Colors.grey[700], fontSize: 12),
                  );
                }).toList(),
              ),
            ),
          Row(
            children: [
              // Add tags button
              GestureDetector(
                onTap: () => _showAddTagDialog(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tag, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Add Tags',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Settings button
              GestureDetector(
                onTap: () {
                  // TODO: Show settings
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.settings_outlined,
                        size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Word count
              Text(
                '${state.wordCount} words',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Publish button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: state.status == ArticleEditorStatus.publishing
                  ? null
                  : () => _publish(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B5BDB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.status == ArticleEditorStatus.publishing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Publish Article',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 630,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        context.read<ArticleEditorCubit>().setLocalImage(pickedFile.path);
      }
    }
  }

  void _showAddTagDialog(BuildContext context) {
    _tagController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: _tagController,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
            prefixText: '#',
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<ArticleEditorCubit>().addCategory(value.trim());
              Navigator.pop(dialogContext);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_tagController.text.isNotEmpty) {
                context
                    .read<ArticleEditorCubit>()
                    .addCategory(_tagController.text.trim());
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveDraft(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is auth.Authenticated) {
      context.read<ArticleEditorCubit>().saveDraft(
            authorId: authState.user!.id ?? '',
            authorName: authState.user!.displayName ?? 'Anonymous',
          );
    }
  }

  void _publish(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is auth.Authenticated) {
      context.read<ArticleEditorCubit>().publishArticle(
            authorId: authState.user!.id ?? '',
            authorName: authState.user!.displayName ?? 'Anonymous',
          );
    }
  }

  void _onClose(BuildContext context, ArticleEditorState state) {
    if (state.hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to save your draft before leaving?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _saveDraft(context);
              },
              child: const Text('Save Draft'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }
}
