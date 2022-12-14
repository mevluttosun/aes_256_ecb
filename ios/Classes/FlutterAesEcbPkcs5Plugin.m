#import "FlutterAesEcbPkcs5Plugin.h"
#import <CommonCrypto/CommonCryptor.h>
#import <Foundation/Foundation.h>


@implementation FlutterAesEcbPkcs5Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_aes_ecb_pkcs5"
            binaryMessenger:[registrar messenger]];
  FlutterAesEcbPkcs5Plugin* instance = [[FlutterAesEcbPkcs5Plugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {

      NSDictionary *argsMap  = call.arguments;

    if ([@"getPlatformVersion" isEqualToString:call.method]) {
      result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([@"generateDesKey" isEqualToString:call.method]) {

        id length = [argsMap objectForKey:@"length"];
        NSLog(@"obj = %@", length);

        NSString *key = [FlutterAesEcbPkcs5Plugin randomlyGeneratedBitString:length];
        //NSLog(@"AES加密的秘钥key=%@",key);

        NSString *hexKey = [FlutterAesEcbPkcs5Plugin hexStringFromString:key];

        //NSLog(@"AES加密的秘钥hexKey=%@",hexKey);

        result(hexKey.uppercaseString);

    }else if ([@"encrypt" isEqualToString:call.method]) {

        id input = [argsMap objectForKey:@"input"];
        //NSLog(@"obj = %@", input);
        id key = [argsMap objectForKey:@"key"];
        //NSLog(@"obj = %@", key);

        NSString *encode = [FlutterAesEcbPkcs5Plugin encyptPKCS5:input WithKey:key];

        //NSLog(@"结果=%@",encode.uppercaseString);
        result(encode.uppercaseString);
    } else if ([@"decrypt" isEqualToString:call.method]) {

        id input = [argsMap objectForKey:@"input"];
        //NSLog(@"obj = %@", input);
        id key = [argsMap objectForKey:@"key"];
        //NSLog(@"obj = %@", key);

        NSString *encode = [FlutterAesEcbPkcs5Plugin decrypPKCS5:input WithKey:key];

        //NSLog(@"结果=%@",encode);
        result(encode);

    } else {
      result(FlutterMethodNotImplemented);
    }

}


+ (NSString *)randomlyGeneratedBitString:(id)length
{
    NSString *string = [[NSString alloc]init];

    NSLog(@"len->%@",length);
    int len = [length intValue] / 8 ;
    NSLog(@"len->%d",len);

    for (int i = 0; i < len; i++) {
        int number = arc4random() % 36;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            string = [string stringByAppendingString:tempString];
        }else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }
    }
    return  string;
}

//字符串加密(16进制)
//字符串加密(16进制)
//字符串加密(16进制)
+ (NSString *)encyptPKCS5:(NSString *)plainText WithKey:(NSString *)key
    {
        // Convert hexadecimal string key to a byte array
        uint8_t *keyBytes = (uint8_t *)hexStringToBytes(key);

        // Convert hexadecimal string to a byte array
        uint8_t *data = (uint8_t *)hexStringToBytes(plainText);

        // Calculate the size of the decrypted data
        size_t dataLength = [plainText length] / 2;
        size_t decryptedDataLength = dataLength;

        // Create a buffer to hold the decrypted data
        uint8_t *decryptedData = malloc(decryptedDataLength);

        // Attempt to decrypt the data
        CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionECBMode,
                                              keyBytes, kCCKeySizeAES256, NULL,
                                              data, dataLength,
                                              decryptedData, decryptedDataLength,
                                              &decryptedDataLength);

        // Check for decryption errors
        if (cryptStatus != kCCSuccess) {
            // Handle error
        }

        // Convert the decrypted data to a hexadecimal string
        NSString *decryptedString = bytesToHexString(decryptedData, decryptedDataLength);

        // Free the allocated memory
        free(keyBytes);
        free(data);
        free(decryptedData);

        // Return the decrypted string
        return decryptedString;
    }

//解密
+(NSString *)decrypPKCS5:(NSString *)encryptText WithKey:(NSString *)key
{
    // Convert hexadecimal string key to a byte array
    uint8_t *keyBytes = (uint8_t *)hexStringToBytes(key);

    // Convert hexadecimal string to a byte array
    uint8_t *data = (uint8_t *)hexStringToBytes(encryptText);

    // Calculate the size of the decrypted data
    size_t dataLength = [encryptText length] / 2;
    size_t decryptedDataLength = dataLength;

    // Create a buffer to hold the decrypted data
    uint8_t *decryptedData = malloc(decryptedDataLength);

    // Attempt to decrypt the data
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionECBMode,
                                          keyBytes, kCCKeySizeAES256, NULL,
                                          data, dataLength,
                                          decryptedData, decryptedDataLength,
                                          &decryptedDataLength);

    // Check for decryption errors
    if (cryptStatus != kCCSuccess) {
        // Handle error
    }

    // Convert the decrypted data to a hexadecimal string
    NSString *decryptedString = bytesToHexString(decryptedData, decryptedDataLength);

    // Free the allocated memory
    free(keyBytes);
    free(data);
    free(decryptedData);

    // Return the decrypted string
    return decryptedString;
}

// Define function to convert a hexadecimal string to a byte array
void * hexStringToBytes(NSString *hexString) {
    NSUInteger hexStringLength = [hexString length];
    if (hexStringLength % 2 != 0) {
        return NULL;
    }
    NSUInteger byteArrayLength = hexStringLength / 2;
    uint8_t *byteArray = malloc(byteArrayLength);
    for (NSUInteger i = 0; i < byteArrayLength; i++) {
        NSString *hexByteString = [hexString substringWithRange:NSMakeRange(i * 2, 2)];
        uint8_t byte = 0;
        sscanf([hexByteString cStringUsingEncoding:NSASCIIStringEncoding], "%x", &byte);
        byteArray[i] = byte;
    }
    return byteArray;
}

// Define function to convert a byte array to a hexadecimal string
NSString * bytesToHexString(void *bytes, NSUInteger length) {
    uint8_t *byteArray = (uint8_t *)bytes;
    NSMutableString *hexString = [[NSMutableString alloc] initWithCapacity:length * 2];
    for (NSUInteger i = 0; i < length; i++) {
        [hexString appendFormat:@"%02x", byteArray[i]];
    }
    return hexString;
}


+ (unsigned char *)convertHexStrToChar:(NSString *)hexString {

    // Calculate the length of the character array
    int mallocLen = [hexString length] / 2 + 1;

    // Allocate memory for the character array
    unsigned char *myBuffer = (unsigned char *)malloc(mallocLen);

    // Initialize all elements in the array to the null character
    memset(myBuffer,'\0',mallocLen);

    // Iterate over the input hexadecimal string in pairs of characters
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];

        // Check if the current pair of characters is "00"
        if ([hexCharStr isEqualToString:@"00"]) {
            // If it is, store the value 0x01 instead of 0x00
            // in the character array to avoid truncating the array
            anInt = 0x01;
        } else {
            // Otherwise, use the NSScanner to convert the hexadecimal value
            NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
            [scanner scanHexInt:&anInt];
        }

        // Convert the unsigned int value to a char and store it in the array
        myBuffer[i / 2] = (unsigned char)anInt;
    }

    // Return the character array containing the converted values
    return myBuffer;
}



+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSString *)hexStringForData:(NSData *)data
{
    if (data == nil) {
        return nil;
    }
    
    NSMutableString *hexString = [NSMutableString string];
    
    const unsigned char *p = [data bytes];
    
    for (int i=0; i < [data length]; i++) {
        [hexString appendFormat:@"%02x", *p++];
    }
    
    return hexString;
}


@end
