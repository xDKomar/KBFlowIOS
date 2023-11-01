import UIKit
import Speech

class ViewController: UIViewController {
    // Define your text input field and button
    let textField = UITextField()
    let button = UIButton()
    let clearButton = UIButton(type: .custom)
    let microphoneButton = UIButton()
    
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
    }
    
    @objc func sendPostRequest() {
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
            if let url = URL(string: "https://kanbanflow.com/api/v1/tasks?apiToken=cR4EARu6Lnjmww4ipKAvAzPcAZ") {
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
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU")) // Specify the desired locale
    
    @objc func startVoiceInput() {
        // Check if speech recognition is available
        guard let recognizer = speechRecognizer else {
            print("Speech recognition is not available.")
            return
        }

        SFSpeechRecognizer.requestAuthorization { (status) in
            if status == .authorized {
                let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                let audioEngine = AVAudioEngine()

                do {
                    try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

                    let inputNode = audioEngine.inputNode

                    let recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { (result, error) in
                        if let result = result {
                            let bestString = result.bestTranscription.formattedString
                            DispatchQueue.main.async {
                                self.textField.text = bestString
                            }
                        }
                    }

                    let recordingFormat = inputNode.outputFormat(forBus: 0)
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                        recognitionRequest.append(buffer)
                    }

                    audioEngine.prepare()

                    do {
                        try audioEngine.start()
                    } catch {
                        print("Audio engine couldn't start because of an error: \(error.localizedDescription)")
                    }
                } catch {
                    print("Failed to configure audio session: \(error.localizedDescription)")
                }
            } else {
                print("Speech recognition authorization denied.")
            }
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
