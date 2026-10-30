import 'package:url_launcher/url_launcher.dart';

class ContactService {
  ContactService._();

  // DATA DUMMY UNTUK UTS
  // Nomor hanya contoh format, bukan kontak resmi.
  static const String sellerPhone = '628559999127';

  // Lokasi contoh menggunakan landmark publik di Solo.
  // Bukan alamat agen resmi Rupa Rempah Solo.
  static const String mapsQuery =
      'PT. Samsudi Indoniaga Sedaya';

  // WhatsApp does not support a public link that starts a voice call directly.
  // Open the seller's WhatsApp chat so the user can start a call there.
  static Future<bool> callSeller() async {
    return _openWhatsApp();
  }

  // Send the SMS action to WhatsApp with a prefilled message.
  static Future<bool> smsSeller() async {
    return _openWhatsApp(
      message: 'Halo Rupa Rempah Solo, saya ingin bertanya tentang produk.',
    );
  }

  static Future<bool> _openWhatsApp({String? message}) {
    final url = Uri.https(
      'wa.me',
      '/$sellerPhone',
      message == null ? null : {'text': message},
    );
    return launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  // GOOGLE MAPS
  static Future<bool> openMaps() async {
    final url = Uri.https(
      'www.google.com',
      '/maps/search/',
      {
        'api': '1',
        'query': mapsQuery,
      },
    );

    return launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}
