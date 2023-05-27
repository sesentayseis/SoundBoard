
import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    @IBOutlet weak var tiempoDuracionLabel: UILabel!
    
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    // tiempo
    var grabacionActualDuracion: TimeInterval = 0.0
    var duracionTimer: Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled=false
        agregarButton.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            detenerDuracionTimer()
            actualizarTiempoDuracionLabel()
        }else {
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            agregarButton.isEnabled = false
            iniciarDuracionTimer()
        }


    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch{}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as!
            AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)

    }
    
    func configurarGrabacion(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default,
                options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)


            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,
                true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!


            print("********************")
            print(audioURL!)
            print("********************")
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?


            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        }catch let error as NSError{
            print(error)
        }
    }
    // MARK: - Métodos de tiempo
    
    func iniciarDuracionTimer() {
        duracionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempoDuracionLabel), userInfo: nil, repeats: true)
    }

    func detenerDuracionTimer() {
        duracionTimer?.invalidate()
        duracionTimer = nil
    }

    
    @objc func actualizarTiempoDuracionLabel() {
        if let grabarAudio = grabarAudio {
            grabacionActualDuracion = grabarAudio.currentTime
            let tiempoFormateado = formatearTiempoDuracion(grabacionActualDuracion)
            tiempoDuracionLabel.text = tiempoFormateado
        }
    }

    func formatearTiempoDuracion(_ duracion: TimeInterval) -> String {
        let minutos = Int(duracion / 60)
        let segundos = Int(duracion.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutos, segundos)
    }

}
