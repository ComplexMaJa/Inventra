import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onHighlightChanged: (isHighlighted) {
            setState(() => _scale = isHighlighted ? 0.97 : 1.0);
          },
          onTap: widget.onEdit,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Fixed-size square image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: widget.product.imageBase64 != null
                        ? Image.memory(
                            base64Decode(widget.product.imageBase64!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                          )
                        : (widget.product.imagePath != null
                            ? Image(
                                image: kIsWeb
                                    ? NetworkImage(widget.product.imagePath!) as ImageProvider
                                    : FileImage(File(widget.product.imagePath!)),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                              )
                            : const Icon(Icons.image_not_supported, size: 32, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Center: Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C4DFF).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              widget.product.category,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7C4DFF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (() {
                          String str = widget.product.price.toStringAsFixed(0);
                          String result = '';
                          for (int i = 0; i < str.length; i++) {
                            if (i > 0 && (str.length - i) % 3 == 0) {
                              result += '.';
                            }
                            result += str[i];
                          }
                          return 'Rp $result';
                        })(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7C4DFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Stock: ${widget.product.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.product.stock < 5 ? Colors.orange[400] : Colors.grey,
                              fontWeight: widget.product.stock < 5 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (widget.product.stock < 5) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Low Stock',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.orange[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ]
                      ),
                      if (widget.product.description != null && widget.product.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.product.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // Right: Actions
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: Colors.grey[400],
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      onPressed: widget.onEdit,
                      tooltip: 'Edit',
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: Colors.red[300],
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                      onPressed: widget.onDelete,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
