import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:inkwel_blog_app/core/constants/constants.dart';
import 'package:inkwel_blog_app/core/error/exception.dart';
import 'package:inkwel_blog_app/core/error/failures.dart';
import 'package:inkwel_blog_app/core/network/connection_checker.dart';
import 'package:inkwel_blog_app/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:inkwel_blog_app/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:inkwel_blog_app/features/blog/data/models/blog_model.dart';
import 'package:inkwel_blog_app/features/blog/domain/entities/blog.dart';
import 'package:inkwel_blog_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;
  final BlogLocalDataSource blogLocalDataSource;
  final ConncectionChecker conncectionChecker;
  BlogRepositoryImpl(
    this.blogRemoteDataSource,
    this.blogLocalDataSource,
    this.conncectionChecker,
  );

  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      if (!await (conncectionChecker.isConnected)) {
        return left(Failure(Constatns.noConnectionErrorMessage));
      }
      BlogModel blogModel = BlogModel(
        id: const Uuid().v1(),
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: '',
        topics: topics,
        updateAt: DateTime.now(),
      );
      final imageUrl = await blogRemoteDataSource.uploadBlogImage(
        image: image,
        blog: blogModel,
      );
      blogModel = blogModel.copyWith(imageUrl: imageUrl);
      final uploadedBlog = await blogRemoteDataSource.uploadBlog(blogModel);
      return right(uploadedBlog);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
      if (!await (conncectionChecker.isConnected)) {
        final blogs = blogLocalDataSource.loadBlogs();
        return right(blogs);
      }
      final blogs = await blogRemoteDataSource.getAllBlogs();
      blogLocalDataSource.uploadLocalBlogs(blogs: blogs);
      return right(blogs);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
