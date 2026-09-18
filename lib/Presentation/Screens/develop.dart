import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class DevelopScreen extends StatefulWidget {
  const DevelopScreen({super.key});

  @override
  State<DevelopScreen> createState() => _DevelopScreenState();
}

class _DevelopScreenState extends State<DevelopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('توسعه دهندگان'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3_outline),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
              child: Row(
                children: [
                  Icon(
                    Iconsax.people_outline,
                    size: 30,
                  ),
                  SizedBox(width: 5),
                  Text(
                    ' اعضای تیم توسعه دهنده  ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const SizedBox(width: 15),
                Neumorphic(
                  style: NeumorphicStyle(
                    color: Colors.white,
                    shadowDarkColor: Colors.black87,
                    depth: 6,
                    intensity: 0.8,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
                  ),
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/DevSupervisor.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'محمد چهانگیر',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'سرپرست تیم توسعه دهندگان',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: IconButton(
                    tooltip: 'Telegram',
                    icon: const Icon(
                      Bootstrap.telegram,
                      size: 30,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      await launchUrl(
                          Uri.parse('https://t.me/mjahan99'),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 15),
                Neumorphic(
                  style: NeumorphicStyle(
                    color: Colors.white,
                    shadowDarkColor: Colors.black87,
                    depth: 6,
                    intensity: 0.8,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
                  ),
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/DevDjango.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سید محمد موسوی',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'توسعه دهنده سمت سرور  ( Django - Python )',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: IconButton(
                    tooltip: 'Github',
                    icon: const Icon(
                      Bootstrap.github,
                      size: 30,
                    ),
                    onPressed: () async {
                      await launchUrl(
                          Uri.parse('https://github.com/Bestsenator'),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 15),
                Neumorphic(
                  style: NeumorphicStyle(
                    color: Colors.white,
                    shadowDarkColor: Colors.black87,
                    depth: 6,
                    intensity: 0.8,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
                  ),
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/DevFlutter.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'علی نجف زاده',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'توسعه دهنده نرم افزار ( Flutter - Dart )',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: IconButton(
                    tooltip: 'Github',
                    icon: const Icon(
                      Bootstrap.github,
                      size: 30,
                    ),
                    onPressed: () async {
                      await launchUrl(
                          Uri.parse('https://github.com/AliNajafzadeh7916'),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 15),
                Neumorphic(
                  style: NeumorphicStyle(
                    color: Colors.white,
                    shadowDarkColor: Colors.black87,
                    depth: 6,
                    intensity: 0.8,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(40)),
                  ),
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/DevTester.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مصطفی اله‌پور',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'آزمایشگر نرم‌افزار ( Tester qa )',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: IconButton(
                    tooltip: 'Github',
                    icon: const Icon(
                      Bootstrap.github,
                      size: 30,
                    ),
                    onPressed: () async {
                      await launchUrl(
                          Uri.parse('https://github.com/mostafaallahpour'),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width - 50,
              margin: const EdgeInsets.only(bottom: 20, top: 5),
              decoration: DottedDecoration(
                strokeWidth: 2,
                shape: Shape.line,
                linePosition: LinePosition.bottom,
                color: Colors.black,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 20, 10),
              child: Row(
                children: [
                  Icon(
                    Iconsax.device_message_outline,
                    size: 30,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'چند کلامی از زبان توسعه دهندگان ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  Text(
                    '● ما یه تیم دوستانه هستیم که بر اساس علاقه مشترک‌مون به توسعه نرم‌افزار و تجربه‌ای که در پروژه‌های مشابه داشتیم، تصمیم گرفتیم تا این برنامه رو پیاده سازی کنیم. از همون  اول هدف ما ارائه‌ی راه‌حلی بود که نه تنها مشکلات موجود رو برطرف کنه، بلکه امکانات و ویژگی‌های جدیدی رو به کاربران ارائه بده که تجربه کاربری بهتری هم داشته باشه.',
                    style: TextStyle(height: 1.7),
                  ),
                  Text(
                    '● با توجه به تجربه و دانشی که از پروژه‌های قبلی کسب کرده بودیم، تونستیم نیازها و خواسته‌های کاربران رو تا حد مطلوبی شناسایی کنیم و برنامه‌ای طراحی کنیم که قابلیت‌های کاربردی و مفیدی داشته باشه. تلاش ما همیشه بر این بوده که با گوش دادن به بازخوردهای شما و اعمال تغییرات لازم، برنامه‌ای پویا و کاربرپسند ارائه بدیم.',
                    style: TextStyle(height: 1.7),
                  ),
                  Text(
                    '● ما به آینده‌ ی روشن و پربار برای این پروژه باور داریم و همچنان به تلاش برای بهبود و افزودن ویژگی‌های جدید ادامه میدیم. از اینکه به ما اعتماد کردین و از این برنامه استفاده می‌کنین، خیلی خیلی تشکر میکنیم و امیدواریم که بتونیم همچنان انتظارات شما رو برآورده کنیم.',
                    style: TextStyle(height: 1.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50)
          ],
        ),
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Made with ',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Lottie.asset(
                      'assets/lottie/heart.json',
                      height: 25,
                      width: 25,
                    ),
                  ),
                  const TextSpan(
                    text: ' in ',
                  ),
                  const TextSpan(
                      text: 'Torshiz Green Cedar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
