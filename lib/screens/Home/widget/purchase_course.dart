import 'package:flutter/material.dart';
import 'featured_courses.dart'; // Import to access Course model
import 'my_courses.dart'; // Import for navigation to My Courses
import 'course_manager.dart'; // Import CourseManager
import 'package:ramysmart/screens/Home/widget/course_manager.dart';
import 'assignment_model.dart'; // Import for assignment generation

class PurchaseCoursePage extends StatefulWidget {
  final List<Course> courses;
  final double totalPrice;
  // Add a callback function for when purchase is completed
  final VoidCallback? onPurchaseComplete;

  const PurchaseCoursePage({
    Key? key,
    required this.courses,
    required this.totalPrice,
    this.onPurchaseComplete,
  }) : super(key: key);

  @override
  State<PurchaseCoursePage> createState() => _PurchaseCoursePageState();
}

class _PurchaseCoursePageState extends State<PurchaseCoursePage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Payment method selection
  String _paymentMethod = 'Credit Card';
  bool _isProcessing = false;
  bool _paymentSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Purchase Course',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Order summary card
          _buildOrderSummary(),

          // Stepper for checkout process
          Expanded(
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) {
                setState(() {
                  _currentStep = step;
                });
              },
              onStepContinue: () {
                if (_currentStep == 0) {
                  // Validate customer information form
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _currentStep += 1;
                    });
                  }
                } else if (_currentStep == 1) {
                  // Process payment
                  _processPayment();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                }
              },
              steps: [
                Step(
                  title: const Text('Information'),
                  content: _buildCustomerInfoForm(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Payment'),
                  content: _buildPaymentForm(),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Confirmation'),
                  content: _buildConfirmation(),
                  isActive: _currentStep >= 2,
                  state: _currentStep == 2 ? StepState.complete : StepState.indexed,
                ),
              ],
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      if (_currentStep < 2)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              _currentStep == 1 ? 'Pay Now' : 'Continue',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep == 2)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Very important: Call the callback BEFORE navigating
                              // This ensures the course is marked as purchased before the user leaves this page
                              if (widget.onPurchaseComplete != null) {
                                widget.onPurchaseComplete!();
                              }

                              // Navigate directly to My Courses page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MyCourses(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Go to My Courses',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0 && _currentStep < 2) ...[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // List all courses in the cart
          for (var course in widget.courses) ...[
            Row(
              children: [
                // Course icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: course.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    course.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Course title and provider
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        course.provider,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.play_circle_outline, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${course.lessons} Lessons',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${course.minutes} Minutes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Course price
                Text(
                  '\$${course.price.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          const Divider(height: 24),
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text(
                '\$${widget.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Tax
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax (10%)'),
              Text(
                '\$${(widget.totalPrice * 0.1).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          // Total section with tax
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '\$${(widget.totalPrice + (widget.totalPrice * 0.1)).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone field
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Country dropdown
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Country',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.public),
            ),
            items: ['Indonesia', 'United States', 'United Kingdom', 'Japan', 'Australia']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {},
            validator: (value) {
              if (value == null) {
                return 'Please select your country';
              }
              return null;
            },
            value: 'Indonesia',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment method selection
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        // Radio buttons for payment methods
        _buildPaymentMethodTile(
          title: 'Credit Card',
          subtitle: 'Pay with Visa, Mastercard',
          icon: Icons.credit_card,
          value: 'Credit Card',
        ),
        _buildPaymentMethodTile(
          title: 'PayPal',
          subtitle: 'Pay with your PayPal account',
          icon: Icons.account_balance_wallet,
          value: 'PayPal',
        ),
        _buildPaymentMethodTile(
          title: 'Bank Transfer',
          subtitle: 'Pay directly from your bank account',
          icon: Icons.account_balance,
          value: 'Bank Transfer',
        ),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),

        // Credit card form (only show if Credit Card is selected)
        if (_paymentMethod == 'Credit Card')
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Card Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              // Card number field
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
              ),
              const SizedBox(height: 12),

              // Expiry date and CVV fields
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.datetime,
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ),

        // PayPal message
        if (_paymentMethod == 'PayPal')
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You will be redirected to PayPal to complete your payment.',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

        // Bank Transfer message
        if (_paymentMethod == 'Bank Transfer')
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Transfer Instructions',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                SizedBox(height: 8),
                Text('1. Transfer to: Bank XYZ'),
                Text('2. Account Number: 1234-5678-9012-3456'),
                Text('3. Account Name: EduApp'),
                SizedBox(height: 8),
                Text(
                  'Please attach proof of payment to complete your course purchase.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _paymentMethod == value ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: Colors.blue),
        value: value,
        groupValue: _paymentMethod,
        onChanged: (String? value) {
          setState(() {
            _paymentMethod = value!;
          });
        },
        activeColor: Colors.blue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildConfirmation() {
    if (_isProcessing) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing payment...'),
          ],
        ),
      );
    }

    if (_paymentSuccess) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 16),
          const Text(
            'Purchase Complete!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thank you for purchasing ${widget.courses.length} course${widget.courses.length > 1 ? 's' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'A confirmation has been sent to your email address.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'You can now access these courses from your My Courses section.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Course assignments have been automatically generated for you to practice.',
            style: TextStyle(color: Colors.blue),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return const Center(
      child: Text('Something went wrong. Please try again.'),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Processing payment...'),
          ],
        ),
      ),
    );

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Close the loading dialog
    Navigator.pop(context);

    // Add purchased courses to CourseManager and generate assignments
    final courseManager = CourseManager();
    for (var course in widget.courses) {
      courseManager.addCourse(course);
      // Generate assignments for each course
      // This would typically call a method to generate assignments
    }

    setState(() {
      _isProcessing = false;
      _paymentSuccess = true;
      _currentStep = 2; // Move to confirmation step
    });
  }
}