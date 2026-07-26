import '../models/promo_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class MockData {
  static const List<PromoModel> promos = [
    PromoModel(
      id: 'p1',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',
      title: '2x1 en BigMac',
      subtitle: 'Solo hoy en la app',
      badgeText: 'OFERTA',
    ),
    PromoModel(
      id: 'p2',
      imageUrl: 'https://images.unsplash.com/photo-1551782450-a2132b4ba21d?w=600',
      title: 'McDesayuno completo',
      subtitle: 'Disponible hasta las 11am',
      badgeText: 'NUEVO',
    ),
    PromoModel(
      id: 'p3',
      imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=600',
      title: 'McFlurry Oreo',
      subtitle: 'Por tiempo limitado',
      badgeText: 'LIMITED',
    ),
    PromoModel(
      id: 'p4',
      imageUrl: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=600',
      title: 'Cajita Feliz',
      subtitle: 'Con juguete sorpresa',
      badgeText: 'KIDS',
    ),
  ];

  static const List<CategoryModel> categories = [
    CategoryModel(id: 'c0', name: 'Todos', emoji: '🍔'),
    CategoryModel(id: 'c1', name: 'Burgers', emoji: '🍔'),
    CategoryModel(id: 'c2', name: 'Papas', emoji: '🍟'),
    CategoryModel(id: 'c3', name: 'Bebidas', emoji: '🥤'),
    CategoryModel(id: 'c4', name: 'Desayunos', emoji: '🍳'),
    CategoryModel(id: 'c5', name: 'Postres', emoji: '🍦'),
    CategoryModel(id: 'c6', name: 'Ensaladas', emoji: '🥗'),
    CategoryModel(id: 'c7', name: 'Combos', emoji: '🎁'),
  ];

  // 30 productos para stress-test de performance
  static final List<ProductModel> products = List.generate(30, (i) {
    final base = _baseProducts[i % _baseProducts.length];
    return ProductModel(
      id: 'prod_$i',
      name: i < _baseProducts.length ? base.name : '${base.name} ${i + 1}',
      description: base.description,
      price: base.price + (i * 0.10),
      imageUrl: base.imageUrl,
      categoryId: base.categoryId,
      isPopular: i % 3 == 0,
      isNew: i % 5 == 0,
    );
  });

  static const List<ProductModel> _baseProducts = [
    ProductModel(
      id: 'base1', name: 'Big Mac', categoryId: 'c1',
      description: 'Dos filetes de carne, lechuga, queso, pepinillos y salsa especial',
      price: 4.99, imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      isPopular: true,
    ),
    ProductModel(
      id: 'base2', name: 'McPollo Clásico', categoryId: 'c1',
      description: 'Filete de pollo crujiente con lechuga y mayonesa',
      price: 4.49, imageUrl: 'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=400',
    ),
    ProductModel(
      id: 'base3', name: 'Papas Grandes', categoryId: 'c2',
      description: 'Papas fritas crujientes con sal de mar',
      price: 2.49, imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400',
      isPopular: true,
    ),
    ProductModel(
      id: 'base4', name: 'McFlurry Oreo', categoryId: 'c5',
      description: 'Helado suave con galleta Oreo triturada',
      price: 3.29, imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',
      isNew: true,
    ),
    ProductModel(
      id: 'base5', name: 'Coca-Cola Grande', categoryId: 'c3',
      description: 'Refresco frío 500ml',
      price: 1.99, imageUrl: 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400',
    ),
    ProductModel(
      id: 'base6', name: 'McMuffin Huevo', categoryId: 'c4',
      description: 'Muffin inglés con huevo, queso y tocino',
      price: 3.49, imageUrl: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400',
      isNew: true,
    ),
  ];
}