# Text2Img Flutter App
![app designs](https://raw.githubusercontent.com/Sulimalogy/Text2ImgFlutterApp/refs/heads/main/designs/Z.png)

This app is a Flutter based application that generates images from user-provided text using online machine learning models. It supports sving generated images, maintaining a history of images, and reviewing past creations. 

## Full Description
The app leverages Flufter for its frontend and a backend API for image generation. Users input text descriptions, which are transformed into images by an AI model. Generated images can be saved to local storage, and users can browse their creation history.

## Key features:
- Text-to-Image Generation: Users provide a text prompt, and the app returns a visual representation.
- Save & History: Generated images are saved locally, and users can access and review their image history.

## Project Structure
```bash
.
├── lib/
│   ├── main.dart           # Main entry point
│   ├── home.dart           # home screen
│   ├── credentials.dart    # A file you should create see how to use
│   └── api_service.dart    # API requests for generating images
├── README.md               # Project documentation
└── pubspec.yaml            # Dependencies and project metadata
```

## How to Use
1. Clone the repository.
2. Install dependencies:
    ```bash
    flutter pub get
    ```
3. Add Hugging face token in lib/creadentials.dart 
    ```dart
    class Credentials {
      static String apiKey = 'hf_token_here';
    }
    ```    
4. Run the app:
    ```bash
    flutter run
    ```
5. build it yourself 
    ```bash
    flutter build apk --release
    ```
6. Enter a description in the text input field and generate an image. 

  
## References
- Flutter documentation: [https://flutter.dev/docs](https://flutter.dev/docs)
- AI model documentation for text-to-image: [ZB-Tech huggingface model ](https://huggingface.co/ZB-Tech/Text-to-Image)
