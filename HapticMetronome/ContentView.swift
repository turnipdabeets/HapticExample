import AVFoundation
import CoreHaptics
import SwiftUI

struct NotificationFeedback: View {
    var body: some View {
        VStack {
            Button(action: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }, label: {Text("success")}).padding()
            
            Button(action: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }, label: {Text("warning")}).padding()
            
            Button(action: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }, label: {Text("error")}).padding()
        }
    }
}

struct ImpactFeedback: View {
    var body: some View {
        VStack {
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            }, label: {Text("light")}).padding()
            
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
            }, label: {Text("medium")}).padding()
            
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.prepare()
                generator.impactOccurred()
            }, label: {Text("heavy")}).padding()
            
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .rigid)
                generator.prepare()
                generator.impactOccurred()
            }, label: {Text("ridgid")}).padding()
            
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.prepare()
                generator.impactOccurred()
            }, label: {Text("soft")}).padding()
        }
    }
}

struct ContentView: View {
    @State private var engine: CHHapticEngine?
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
            Button(action: play, label: {Text("120 BPM")}).padding()
            Button(action: stop, label: {Text("stop metronome")}).padding()
            Button(action: vibrate, label: {Text("vibrate")}).padding()
            NotificationFeedback()
            ImpactFeedback()
        }.onAppear(perform: prepareHaptics)
    }
    
    func stop(){
        timer?.invalidate()
        timer = nil
    }
    
    func vibrate(){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func play() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            
            if timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    try! player?.start(atTime: 0)
                }
            }
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
