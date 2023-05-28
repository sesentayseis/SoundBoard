
import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaGrabaciones.dataSource = self
        tablaGrabaciones.delegate = self
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return grabaciones.count
        }

   


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "GrabacionCell")
        let grabacion = grabaciones[indexPath.row]
        cell.textLabel?.text = grabacion.nombre
        cell.detailTextLabel?.text = "Duración: \(formatearDuracion(grabacion.duracion))"
        return cell
        */
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "GrabacionCell")
        let grabacion = grabaciones[indexPath.row]
        cell.textLabel?.text = grabacion.nombre
        
        let duracionString = formatearDuracion(grabacion.duracion)
        let duracionAttributedString = NSAttributedString(string: duracionString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        let duracionCompletaString = "Duración: " + duracionAttributedString.string
        let duracionCompletaAttributedString = NSAttributedString(string: duracionCompletaString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        cell.detailTextLabel?.attributedText = duracionCompletaAttributedString
        
        return cell
    }
    
    func formatearDuracion(_ duracion: TimeInterval) -> String {
        let minutos = Int(duracion / 60)
        let segundos = Int(duracion.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutos, segundos)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as!
            AppDelegate).persistentContainer.viewContext
        do{
            grabaciones = try
                context.fetch(Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        }catch{}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        do{
            reproducirAudio = try AVAudioPlayer(data:
                grabacion.audio! as Data)
            reproducirAudio?.play()
        }catch{}
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)

    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let grabacion = grabaciones[indexPath.row]
            let context = (UIApplication.shared.delegate as!
                AppDelegate).persistentContainer.viewContext
            context.delete(grabacion)
            (UIApplication.shared.delegate as!
                AppDelegate).saveContext()
            do{
                grabaciones = try
                    context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            }catch{}
        }
    }
    

}

