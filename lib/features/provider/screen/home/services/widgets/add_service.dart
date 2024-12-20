import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/constants/sizes.dart';
import 'package:pet/features/provider/controller/service_controller.dart';
import '../../../../controller/pdf_controller.dart';
import '../../../../controller/provider_controller.dart';

class AddServicePage extends StatelessWidget {
  final ProviderController controller = Get.find<ProviderController>(); // Use existing instance
  final ImageController imageController = Get.put(ImageController());
  final ServiceController controller1 = Get.put(ServiceController());

  AddServicePage({super.key}) {
    controller1.clearForm(); // Clear fields when navigating to this page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        title: const Text('Add New Service', style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              SizedBox(height: Sizes.s),
              TextFormField(
                controller: controller1.nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the service name';
                  }
                  return null;
                },
              ),
              SizedBox(height: Sizes.s),

              TextFormField(
                controller: controller1.descriptionController,
                decoration: const InputDecoration(labelText: 'Service Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: Sizes.s),

              TextFormField(
                controller: controller1.priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (Rs.)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the service price';
                  }
                  return null;
                },
              ),
              SizedBox(height: Sizes.s),

              TextFormField(
                controller: controller1.durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the service duration';
                  }
                  return null;
                },
              ),
              SizedBox(height: Sizes.s),

              Obx(() => DropdownButtonFormField<String>(
                value: controller1.selectedCategory.value.isNotEmpty ? controller1.selectedCategory.value : null,
                decoration: const InputDecoration(labelText: 'Category'),
                items: controller1.categorySubCategories.keys.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  controller1.selectedCategory.value = value!;
                  controller1.selectedSubCategory.value = controller1.categorySubCategories[value]?.first ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              )),
              SizedBox(height: Sizes.s),

              Obx(() {
                if (controller1.selectedCategory.value.isNotEmpty) {
                  return DropdownButtonFormField<String>(
                    value: controller1.selectedSubCategory.value.isNotEmpty ? controller1.selectedSubCategory.value : null,
                    decoration: const InputDecoration(labelText: 'Subcategory'),
                    items: controller1.categorySubCategories[controller1.selectedCategory.value]!.map((subcategory) {
                      return DropdownMenuItem<String>(
                        value: subcategory,
                        child: Text(subcategory),
                      );
                    }).toList(),
                    onChanged: (value) {
                      controller1.selectedSubCategory.value = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a subcategory';
                      }
                      return null;
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              SizedBox(height: Sizes.s),

              Center(
                child: GestureDetector(
                  onTap: () async {
                    await imageController.pickImageFile(); // Trigger image picker
                  },
                  child: Obx(() {
                    if (imageController.selectedImagePath.value.isNotEmpty) {
                      // Show the selected image
                      return Image.file(
                        File(imageController.selectedImagePath.value),
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                      );
                    } else {
                      // Placeholder UI
                      return Container(
                        width: 300,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 2),
                          color: Colors.grey[100],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 50,
                              color: logoPurple,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tap to upload an image',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                ),
              ),


              SizedBox(height: Sizes.s),

              Obx(() => SwitchListTile(
                title: const Text('Service Available'),
                value: controller1.isAvailable.value,
                onChanged: (value) {
                  controller1.isAvailable.value = value;
                },
              )),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (controller.formKey.currentState!.validate()) {
                    // Ensure image is uploaded
                    String? imageUrl = imageController.uploadUrl.value.isNotEmpty
                        ? imageController.uploadUrl.value
                        : null;

                    if (imageUrl == null) {
                      Get.snackbar("Error", "Please upload an image before proceeding.");
                      return;
                    }

                    // Proceed to add service with the image URL
                    controller1.addService(
                      context,
                      providerId: FirebaseAuth.instance.currentUser?.uid,
                      imageUrl: imageUrl, // Pass the uploaded image URL
                    );
                  }
                },
                child: const Text('Add Service'),
              ),

              SizedBox(height: Sizes.s),
            ],
          ),
        ),
      ),
    );
  }
}

