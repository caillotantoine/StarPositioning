import Foundation

func JD(_ now: Date) -> Double {
    var cal = Calendar.current
    cal.timeZone = TimeZone(abbreviation: "GMT")!
    let Y = cal.component(.year, from: now)
    let M = cal.component(.month, from: now)
    let fracSec = Double(cal.component(.second, from: now))/60
    let fracMin = (Double(cal.component(.minute, from: now))+fracSec)/60.0
    let fracHou = (Double(cal.component(.hour, from: now))+fracMin)/24
    let D = Double(cal.component(.day, from: now))+fracHou
    

    let A = Y/100
    let B = A/4
    let C = 2-A+B
    let E = Int(365.25*Double(Y+4716))
    let F = Int(30.6001*Double(M+1))
    let JD = Double(C+E+F)-1524.5+D
    
    return JD
}

func J2000(_ JJ: Double) -> Double {
    return JJ - 2451545.0
}

func LST(J2000 j: Double, Date t: Date, Long l: Double) -> Double {
    var cal = Calendar.current
    cal.timeZone = TimeZone(abbreviation: "GMT")!
    let fracSec = Double(cal.component(.second, from: t))/60
    let fracMin = (Double(cal.component(.minute, from: t))+fracSec)/60.0
    let UT = Double(cal.component(.hour, from: t))+fracMin
    return (100.46+0.985647*j+l+15*UT).truncatingRemainder(dividingBy: 360.0)
}

func getHA(RA ra: Double, LST l: Double) -> Double {
    return (l-ra).truncatingRemainder(dividingBy: 360.0)
}

func getAltAz (LAT lat: Double, DEC dec: Double, HA ha: Double) -> (ALT: Double, AZ: Double) {
    let ALT = asin(sin(dec*Double.pi/180)*sin(lat*Double.pi/180)+cos(dec*Double.pi/180)*cos(lat*Double.pi/180)*cos(ha*Double.pi/180))
    let A = acos((sin(dec*Double.pi/180)-sin(ALT)*sin(lat*Double.pi/180))/(cos(ALT)*cos(lat*Double.pi/180)))
    var AZ = 0.0
    if sin(ha*Double.pi/180) < 0 {
        AZ = A
    } else {
        AZ = Double.pi - A
    }
    return (ALT*180/Double.pi, AZ*180/Double.pi)
}

func hms2deg(_ h: Double, _ m: Double, _ s: Double) -> Double {
    let Harc = 360.0/24.0
    let Marc = Harc/60.0
    let Sarc = Marc/60.0
    return (Harc*h + Marc*m + Sarc*s)
}

func dms2deg(_ d: Double, _ m: Double, _ s: Double) -> Double {
    let Marc = 1/60.0
    let Sarc = 1/3600.0
    return d + Marc*m + Sarc*s
}

func deg2dms(_ d: Double) -> (DEG: Int, MIN: Int, SEC: Double) {
    let deg = Int(d)
    let min = Int((d-Double(deg))*60.0)
    let sec = (((d-Double(deg))*60.0)-Double(min))*60
    return (deg, min, sec)
}

class Star {
    var Name: String
    var RA: Double
    var DEC: Double
    var Az: Double
    var Alt: Double
    
    
    init(raHMS: (h: Double, m: Double, s: Double), decDMS: (d: Double, m: Double, s: Double), name: String) {
        RA = hms2deg(raHMS.h, raHMS.m, raHMS.s)
        DEC = dms2deg(decDMS.d, decDMS.m, decDMS.s)
        Az = 0.0
        Alt = 0.0
        self.Name = name
    }
    
    func processPosition(Pos: (lat: Double, long: Double), date: Date) {
        let jd = J2000(JD(date))
        let lst = LST(J2000: jd, Date: date, Long: Pos.long)
        let ha = getHA(RA: RA, LST: lst)
        let AltAz = getAltAz(LAT: Pos.lat, DEC: DEC, HA: ha)
        self.Az = AltAz.AZ
        self.Alt = AltAz.ALT
    }
    
    func displayPosition() {
        let altTpl = deg2dms(self.Alt)
        let azTpl = deg2dms(self.Az)
        print("\(self.Name) :")
        print("Alt : \(altTpl.DEG)º \(altTpl.MIN)' \(String(format: "%.2f", altTpl.SEC))'' ")
        print("Az : \(azTpl.DEG)º \(azTpl.MIN)' \(String(format: "%.2f", azTpl.SEC))'' ")
    }
}


let bolbec = (49.5667, 0.4833)
var Arcturus = Star(raHMS: (14, 15, 39.67), decDMS: (19, 10, 56.67), name: "Arcturus")
var Vega = Star(raHMS: (18, 37, 36.2), decDMS: (38, 47, 58.8), name: "Vega")
var Sun = Star(raHMS: (19, 4, 30), decDMS: (63, 52, 0), name: "Sun")

Arcturus.processPosition(Pos: bolbec, date: Date())
Vega.processPosition(Pos: bolbec, date: Date())
Sun.processPosition(Pos: bolbec, date: Date())

Arcturus.displayPosition()
Vega.displayPosition()
Sun.displayPosition()
