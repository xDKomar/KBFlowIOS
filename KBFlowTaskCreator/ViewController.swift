import UIKit
import Speech

class ViewController: UIViewController {
    // Define your text input field and button
    let textField = UITextField()
    let button = UIButton()
    let clearButton = UIButton(type: .custom)
    let microphoneButton = UIButton()
    var isSpeechFinal = false;
    
    let dict: [String: String] = [
        "mon": "71kth5ICZrYi",
        "tue": "727JFEuVyRCR",
        "wed": "73TaKWMZTyh4",
        "thu": "7IzEgr0icxMl",
        "fri": "7JBI2BDvptRN",
        "sat": "7KDvnZOB7Fj7",
        "sun": "7LCvWC9sQrEX",
        "week": "SFDGpwtSDoRC"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: UIImage(named: "gradient"))
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)

        view.addSubview(imageView)
        

        let micConfiguration = UIImage.SymbolConfiguration(pointSize: 72)
        microphoneButton.setImage(UIImage(systemName: "mic.fill", withConfiguration: micConfiguration), for: .normal)
        microphoneButton.tintColor = .white // Customize the color as needed
        microphoneButton.addTarget(self, action: #selector(startVoiceInput), for: .touchUpInside)
        
            
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 42)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: symbolConfiguration),  for: .normal)
        clearButton.tintColor = .white
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        
        
        textField.backgroundColor = .white
        textField.font = UIFont.systemFont(ofSize: 32)
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.becomeFirstResponder()
    
    
        button.setTitle("Add", for: .normal)
        button.backgroundColor = UIColor(hex: "#006ee6")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(sendPostRequest), for: .touchUpInside)
        button.layer.cornerRadius = 10 // Adjust the corner radius as needed
        button.clipsToBounds = true
        
        // Add components to the view
        view.addSubview(microphoneButton)
        view.addSubview(clearButton)
        view.addSubview(textField)
        view.addSubview(button)
        
        // Define layout constraints (you can adjust these as needed)
        textField.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        microphoneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            microphoneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            microphoneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100), // Adjust the spacing as needed

            textField.topAnchor.constraint(equalTo: microphoneButton.bottomAnchor, constant: 50),
            textField.heightAnchor.constraint(equalToConstant: 100),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70),
            
            clearButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 350),
            button.heightAnchor.constraint(equalToConstant: 100)
        
        ])
    }
    
    @objc func clearTextField() {
        textField.text = ""
        isSpeechFinal = true;
    }
    
    @objc func sendPostRequest() {
        isSpeechFinal = true;
        guard let text = textField.text, !text.isEmpty else {
            // Handle case when the text field is empty
            return
        }
        let dayName = DateFormatter().weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1].prefix(3).lowercased()
        let dataDictionary: [String: Any] = [
            "name": text,
            "color":"green",
            "columnId": dict[dayName] ?? "SFDGpwtSDoRC",
            "swimlaneId": "pKwPyEm1lChZ",
            "position": "top"
        ]
        
        do {
            let secrets = Bundle.main.path(forResource: "Secrets", ofType: "plist")
            let secretsDict = NSDictionary(contentsOfFile: secrets!)
            let token = secretsDict!["api-token"] as? String ;
            let urlString = "https://kanbanflow.com/api/v1/tasks?apiToken=" + token!;
            
            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: dataDictionary, options: [])
                
                // Create a URLSession task to send the request
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else if let data = data, let response = response as? HTTPURLResponse {
                        print("Response Status Code: \(response.statusCode)")
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("Response Data: \(responseString)")
                        }
                    }
                }
                task.resume()
            }
        } catch {
            print("Error encoding JSON: \(error)")
        }
        textField.text = "";
    }
     // Specify the desired locale
    
    @objc func startVoiceInput() {
        let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))!
        var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        var recognitionTask: SFSpeechRecognitionTask?
        let audioEngine = AVAudioEngine()
        self.isSpeechFinal = false
        do {
            try startRecording();
        } catch {
            print("Recognition issues")
        }
        func startRecording() throws {
          
          // Cancel the previous recognition task.
          recognitionTask?.cancel()
          recognitionTask = nil
          
          // Audio session, to get information from the microphone.
          let audioSession = AVAudioSession.sharedInstance()
          try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
          try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
          let inputNode = audioEngine.inputNode
          
          // The AudioBuffer
          recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
          recognitionRequest!.shouldReportPartialResults = true
          
          // Force speech recognition to be on-device
          if #available(iOS 13, *) {
            recognitionRequest!.requiresOnDeviceRecognition = true
          }
          
          // Actually create the recognition task. We need to keep a pointer to it so we can stop it.
          recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
              
            
            if let result = result {
                if(!self.isSpeechFinal)
                {
                    self.textField.text = result.bestTranscription.formattedString;
                }
                
            }
            
              if error != nil || self.isSpeechFinal {
              // Stop recognizing speech if there is a problem.
              audioEngine.stop()
              inputNode.removeTap(onBus: 0)
              
              recognitionRequest = nil
              recognitionTask = nil
            }
          }
          
          // Configure the microphone.
          let recordingFormat = inputNode.outputFormat(forBus: 0)
            // The buffer size tells us how much data should the microphone record before dumping it into the recognition request.
          inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            recognitionRequest?.append(buffer)
          }
          
          audioEngine.prepare()
          try audioEngine.start()
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
