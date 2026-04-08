import 'package:flutter_test/flutter_test.dart';
import 'package:kossti/models/product.dart';
import 'package:kossti/models/category.dart';
import 'package:kossti/models/brand.dart';
import 'package:kossti/models/review.dart';
import 'package:kossti/models/user.dart';

void main() {
  group('Product model', () {
    test('fromJson creates product correctly', () {
      final json = {
        'id': 1,
        'name': 'Test Product',
        'name_ar': 'منتج اختبار',
        'price': 99.99,
        'slug': 'test-product',
        'is_featured': true,
        'is_active': true,
        'average_rating': 4.5,
        'review_count': 10,
      };
      final product = Product.fromJson(json);
      expect(product.id, 1);
      expect(product.name, 'Test Product');
      expect(product.nameAr, 'منتج اختبار');
      expect(product.price, 99.99);
      expect(product.averageRating, 4.5);
      expect(product.reviewCount, 10);
      expect(product.isFeatured, true);
      expect(product.localizedName('en'), 'Test Product');
      expect(product.localizedName('ar'), 'منتج اختبار');
    });

    test('toJson serializes product correctly', () {
      final product = Product(
        id: 1,
        name: 'Test',
        nameAr: 'اختبار',
        price: 50.0,
        slug: 'test',
      );
      final json = product.toJson();
      expect(json['id'], 1);
      expect(json['name'], 'Test');
      expect(json['price'], 50.0);
    });
  });

  group('Category model', () {
    test('fromJson creates category correctly', () {
      final json = {
        'id': 1,
        'name': 'Electronics',
        'name_ar': 'إلكترونيات',
        'slug': 'electronics',
        'product_count': 25,
      };
      final cat = Category.fromJson(json);
      expect(cat.id, 1);
      expect(cat.name, 'Electronics');
      expect(cat.nameAr, 'إلكترونيات');
      expect(cat.productCount, 25);
      expect(cat.localizedName('en'), 'Electronics');
      expect(cat.localizedName('ar'), 'إلكترونيات');
    });
  });

  group('Brand model', () {
    test('fromJson creates brand correctly', () {
      final json = {
        'id': 1,
        'name': 'Samsung',
        'name_ar': 'سامسونج',
        'slug': 'samsung',
        'product_count': 50,
      };
      final brand = Brand.fromJson(json);
      expect(brand.id, 1);
      expect(brand.name, 'Samsung');
      expect(brand.localizedName('ar'), 'سامسونج');
    });
  });

  group('User model', () {
    test('fromJson creates user correctly', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'role': 'admin',
      };
      final user = User.fromJson(json);
      expect(user.id, 1);
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.isAdmin, true);
    });

    test('non-admin user', () {
      final json = {
        'id': 2,
        'name': 'Jane',
        'email': 'jane@example.com',
        'role': 'user',
      };
      final user = User.fromJson(json);
      expect(user.isAdmin, false);
    });
  });

  group('Review model', () {
    test('fromJson creates review correctly', () {
      final json = {
        'id': 1,
        'product_id': 1,
        'title': 'Great product',
        'body': 'Really enjoyed using this.',
        'rating': 5.0,
        'status': 'approved',
        'created_at': '2024-01-01T00:00:00.000Z',
        'helpful_count': 3,
      };
      final review = Review.fromJson(json);
      expect(review.id, 1);
      expect(review.rating, 5.0);
      expect(review.isApproved, true);
      expect(review.isPending, false);
    });

    test('pending review status', () {
      final json = {
        'id': 2,
        'product_id': 1,
        'title': 'Pending',
        'body': 'Waiting for approval.',
        'rating': 3.0,
        'status': 'pending',
        'created_at': '2024-01-01T00:00:00.000Z',
      };
      final review = Review.fromJson(json);
      expect(review.isPending, true);
      expect(review.isApproved, false);
    });
  });
}
