import SwiftUI

struct MaleScores: View {
    @State private var pullUpsCount: Double = 0
    @State private var jumpDistanceInches: Double = 73 // Starting at 6'01" (73 inches)
    @State private var sitUpsCount: Double = 0
    @State private var pushUpsCount: Double = 0
    @State private var runTimeIndex: Int = 0
    @State private var aftTimeInSeconds: Int = (14 * 60) + 1  // Starting at 14:01
    
    let pullUpScores: [Int] = [0, 2, 5, 9, 13, 17, 21, 25, 30, 35, 40, 45, 50, 55, 60, 66, 71, 77, 82, 88, 94, 100]
    
    let jumpScores: [Int: Int] = [
        73: 0, 74: 1, 75: 3, 76: 5, 77: 7, 78: 9, 79: 12, 80: 14, 81: 17, 82: 20, 83: 23, 84: 25, 85: 29, 86: 32, 87: 36,
        88: 39, 89: 42, 90: 46, 91: 50, 92: 53, 93: 57, 94: 60, 95: 64, 96: 68, 97: 72, 98: 76, 99: 80, 100: 84, 101: 88,
        102: 91, 103: 96, 104: 100
    ]
    
    let sitUpScores: [Int: Int] = [
        0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0, 10: 0, 11: 0, 12: 0, 13: 0, 14: 0, 15: 0, 16: 0,
        17: 0, 18: 0, 19: 0, 20: 0, 21: 0, 22: 0, 23: 0, 24: 0, 25: 0, 26: 0, 27: 0, 28: 0, 29: 0, 30: 0, 31: 0, 32: 0,
        33: 0, 34: 0, 35: 0, 36: 0, 37: 0, 38: 0, 39: 0, 40: 0, 41: 0, 42: 0, 43: 1, 44: 2, 45: 4, 46: 5, 47: 7, 48: 8,
        49: 10, 50: 11, 51: 13, 52: 15, 53: 16, 54: 18, 55: 20, 56: 22, 57: 23, 58: 25, 59: 27, 60: 29, 61: 31, 62: 33,
        63: 34, 64: 36, 65: 38, 66: 40, 67: 42, 68: 44, 69: 46, 70: 48, 71: 50, 72: 52, 73: 54, 74: 56, 75: 58, 76: 60,
        77: 62, 78: 64, 79: 66, 80: 68, 81: 70, 82: 72, 83: 74, 84: 77, 85: 79, 86: 81, 87: 83, 88: 85, 89: 87, 90: 89,
        91: 91, 92: 94, 93: 96, 94: 98, 95: 100
    ]
    
    let pushUpScores: [Int: Int] = [
        0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0,
        10: 0, 11: 0, 12: 0, 13: 0, 14: 0, 15: 0, 16: 0, 17: 0, 18: 0, 19: 1,
        20: 2, 21: 3, 22: 4, 23: 6, 24: 7, 25: 9, 26: 10, 27: 12, 28: 13, 29: 15,
        30: 16, 31: 18, 32: 20, 33: 21, 34: 23, 35: 25, 36: 27, 37: 29, 38: 30, 39: 32,
        40: 34, 41: 36, 42: 38, 43: 40, 44: 42, 45: 44, 46: 45, 47: 47, 48: 50, 49: 51,
        50: 53, 51: 55, 52: 57, 53: 59, 54: 61, 55: 64, 56: 66, 57: 68, 58: 70, 59: 72,
        60: 74, 61: 76, 62: 78, 63: 80, 64: 82, 65: 85, 66: 87, 67: 89, 68: 90, 69: 93,
        70: 96, 71: 98, 72: 100
    ]
    
    let runTimesInSeconds: [Int] = Array(stride(from: 133, through: 95, by: -1))
    let runScores: [Int: Int] = [
        133: 0, 132: 2, 131: 5, 130: 7, 129: 10, 128: 12, 127: 14, 126: 17, 125: 19, 124: 22,
        123: 25, 122: 26, 121: 29, 120: 31, 119: 34, 118: 36, 117: 39, 116: 41, 115: 44, 114: 46,
        113: 50, 112: 52, 111: 54, 110: 57, 109: 59, 108: 62, 107: 65, 106: 67, 105: 70, 104: 73,
        103: 75, 102: 78, 101: 81, 100: 84, 99: 87, 98: 90, 97: 93, 96: 96, 95: 100
    ]
    
    let maxAftTimeInSeconds = 14 * 60 + 1 // 14:01
    let minAftTimeInSeconds = 7 * 60 + 45 // 7:45
    
    let aftTimesToScores: [Int: Int] = [
        465: 500, 466: 499, 467: 498, 468: 497, 469: 497, 470: 496, 471: 496, 472: 495, 473: 495, 474: 494,
        475: 493, 476: 492, 477: 492, 478: 491, 479: 491, 480: 490, 481: 490, 482: 489, 483: 489, 484: 488,
        485: 488, 486: 487, 487: 487, 488: 486, 489: 486, 490: 485, 491: 484, 492: 483, 493: 483, 494: 482,
        495: 482, 496: 481, 497: 480, 498: 479, 499: 479, 500: 478, 501: 477, 502: 476, 503: 476, 504: 475,
        505: 474, 506: 473, 507: 472, 508: 471, 509: 470, 510: 469, 511: 468, 512: 467, 513: 466, 514: 465,
        515: 464, 516: 463, 517: 462, 518: 462, 519: 461, 520: 461, 521: 460, 522: 459, 523: 458, 524: 457,
        525: 456, 526: 456, 527: 455, 528: 454, 529: 453, 530: 453, 531: 452, 532: 451, 533: 450, 534: 449,
        535: 447, 536: 445, 537: 443, 538: 443, 539: 441, 540: 441, 541: 439, 542: 439, 543: 437, 544: 437,
        545: 425, 546: 424, 547: 422, 548: 420, 549: 418, 550: 416, 551: 414, 552: 414, 553: 412, 554: 412,
        555: 410, 556: 410, 557: 408, 558: 406, 559: 404, 560: 402, 561: 400, 562: 400, 563: 399, 564: 399,
        565: 397, 566: 397, 567: 395, 568: 395, 569: 393, 570: 393, 571: 391, 572: 391, 573: 389, 574: 387,
        575: 385, 576: 383, 577: 381, 578: 381, 579: 379, 580: 379, 581: 377, 582: 375, 583: 373, 584: 373,
        585: 371, 586: 371, 587: 370, 588: 369, 589: 367, 590: 363, 591: 361, 592: 359, 593: 357, 594: 355,
        595: 353, 596: 351, 597: 349, 598: 347, 599: 345, 600: 343, 601: 341, 602: 339, 603: 337, 604: 335,
        605: 333, 606: 331, 607: 330, 608: 327, 609: 325, 610: 325, 611: 323, 612: 321, 613: 319, 614: 319,
        615: 317, 616: 317, 617: 315, 618: 313, 619: 311, 620: 309, 621: 307, 622: 305, 623: 303, 624: 301,
        625: 299, 626: 297, 627: 295, 628: 295, 629: 293, 630: 293, 631: 291, 632: 291, 633: 290, 634: 290,
        635: 290, 636: 290, 637: 290, 638: 285, 639: 285, 640: 285, 641: 285, 642: 285, 643: 280, 644: 280,
        645: 280, 646: 280, 647: 280, 648: 275, 649: 275, 650: 275, 651: 275, 652: 275, 653: 270, 654: 270,
        655: 270, 656: 270, 657: 270, 658: 265, 659: 265, 660: 265, 661: 265, 662: 265, 663: 260, 664: 260,
        665: 260, 666: 260, 667: 260, 668: 255, 669: 255, 670: 255, 671: 255, 672: 255, 673: 250, 674: 250,
        675: 250, 676: 249, 677: 249, 678: 249, 679: 249, 680: 249, 681: 244, 682: 244, 683: 244, 684: 244,
        685: 244, 686: 244, 687: 244, 688: 244, 689: 239, 690: 239, 691: 239, 692: 239, 693: 239, 694: 239,
        695: 239, 696: 239, 697: 234, 698: 234, 699: 234, 700: 234, 701: 234, 702: 234, 703: 229, 704: 229,
        705: 229, 706: 229, 707: 229, 708: 229, 709: 229, 710: 229, 711: 226, 712: 226, 713: 226, 714: 226,
        715: 226, 716: 225, 717: 225, 718: 225, 719: 225, 720: 225, 721: 220, 722: 220, 723: 220, 724: 220,
        725: 220, 726: 215, 727: 215, 728: 215, 729: 215, 730: 215, 731: 210, 732: 210, 733: 210, 734: 210,
        735: 210, 736: 205, 737: 205, 738: 205, 739: 205, 740: 205, 741: 200, 742: 200, 743: 200, 744: 200,
        745: 200, 746: 190, 747: 150, 748: 150, 749: 150, 750: 150, 751: 150, 752: 150, 753: 150, 754: 150,
        755: 150, 756: 150, 757: 150, 758: 150, 759: 150, 760: 150, 761: 150, 762: 150, 763: 150, 764: 150,
        765: 150, 766: 150, 767: 150, 768: 150, 769: 150, 770: 150, 771: 150, 772: 150, 773: 150, 774: 150,
        775: 150, 776: 150, 777: 150, 778: 150, 779: 150, 780: 150, 781: 100, 782: 100, 783: 100, 784: 100,
        785: 100, 786: 100, 787: 100, 788: 100, 789: 100, 790: 100, 791: 100, 792: 100, 793: 100, 794: 100,
        795: 100, 796: 100, 797: 100, 798: 100, 799: 100, 800: 100, 801: 100, 802: 100, 803: 100, 804: 100,
        805: 100, 806: 100, 807: 100, 808: 100, 809: 100, 810: 100, 811: 50, 812: 50, 813: 50, 814: 50, 815: 50,
        816: 50, 817: 50, 818: 50, 819: 50, 820: 50, 821: 50, 822: 50, 823: 50, 824: 50, 825: 50, 826: 50,
        827: 50, 828: 50, 829: 50, 830: 50, 831: 50, 832: 50, 833: 50, 834: 50,
        835: 50, 836: 50, 837: 50, 838: 50, 839: 50, 840: 50
    ]
    
    var aftScore: Int {
        return aftTimesToScores[aftTimeInSeconds] ?? 0
    }
    
    struct GradeScale {
        var pointScale: Double
        var grade: String
        var scoreRange: ClosedRange<Int>
    }
    
    let gradeScales = [
        GradeScale(pointScale: 4.0, grade: "A", scoreRange: 476...500),
        GradeScale(pointScale: 3.7, grade: "A-", scoreRange: 451...475),
        GradeScale(pointScale: 3.3, grade: "B+", scoreRange: 426...450),
        GradeScale(pointScale: 3.0, grade: "B", scoreRange: 400...425),
        GradeScale(pointScale: 2.7, grade: "B-", scoreRange: 371...399),
        GradeScale(pointScale: 2.5, grade: "N/A", scoreRange: 331...370),
        GradeScale(pointScale: 2.3, grade: "C+", scoreRange: 291...330),
        GradeScale(pointScale: 2.0, grade: "C", scoreRange: 250...290),
        GradeScale(pointScale: 1.7, grade: "C-", scoreRange: 226...249),
        GradeScale(pointScale: 1.0, grade: "D", scoreRange: 200...225),
        GradeScale(pointScale: 0.0, grade: "N/A", scoreRange: 0...199)
    ]
    
    func gradeAndScale(for score: Int) -> (grade: String, pointScale: Double) {
        for scale in gradeScales {
            if scale.scoreRange.contains(score) {
                return (scale.grade, scale.pointScale)
            }
        }
        return ("N/A", 0.0) // In case there is no matching scale
    }
    
    var totalScore: Int {
        // Safe access to pull up scores with bounds checking
        let safeIndex = min(Int(pullUpsCount), pullUpScores.count - 1)
        let pullUpScore = pullUpScores[safeIndex]
        
        // Dictionary accesses with default values to prevent crashes
        let jumpScore = jumpScores[Int(jumpDistanceInches), default: 0]
        let sitUpScore = sitUpScores[Int(sitUpsCount), default: 0]
        let pushUpScore = pushUpScores[Int(pushUpsCount), default: 0]
        
        // Safe access to run scores
        let safeRunTimeIndex = min(max(runTimeIndex, 0), runTimesInSeconds.count - 1)
        let runTime = runTimesInSeconds[safeRunTimeIndex]
        let runScore = runScores[runTime, default: 0]
        
        return pullUpScore + jumpScore + sitUpScore + pushUpScore + runScore
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 1) {
                // AFT Time section
                VStack(spacing: 5) {
                    HStack {
                        Spacer()
                        Text("Male AFT Time")
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    
                    HStack {
                        Slider(value: Binding(
                            get: { Double(maxAftTimeInSeconds - aftTimeInSeconds) },
                            set: { aftTimeInSeconds = maxAftTimeInSeconds - Int($0) }
                        ),
                        in: 0...Double(maxAftTimeInSeconds - minAftTimeInSeconds)
                        )
                        .accentColor(.green)
                    }
                    
                    let minutes = aftTimeInSeconds / 60
                    let seconds = aftTimeInSeconds % 60
                    Text("\(minutes):\(String(format: "%02d", seconds))")
                        .font(.headline)
                }
                
                // AFT Score display
                let scoreDetailsAft = gradeAndScale(for: aftScore)
                Text("Male AFT Score: \(aftScore)")
                    .font(.title)
                    .bold()
                    .padding()
                Text("Grade: \(scoreDetailsAft.grade)   \(String(format: "%.1f", scoreDetailsAft.pointScale))")
                    .bold()
                    .padding()
                
                // PFT Controls
                Group {
                    // Pull Ups
                    VStack(spacing: 3) {
                        Slider(value: $pullUpsCount, in: 0...Double(pullUpScores.count - 1), step: 1)
                            .accentColor(.green)
                        Text("\(Int(pullUpsCount)) Pull-ups")
                            .font(.headline)
                        
                        // Safe access to scores
                        let safeIndex = min(Int(pullUpsCount), pullUpScores.count - 1)
                        Text("\(pullUpScores[safeIndex]) Points")
                            .font(.subheadline)
                    }
                    
                    // Jump Distance
                    VStack(spacing: 3) {
                        Slider(value: $jumpDistanceInches, in: 73...104, step: 1)
                            .accentColor(.green)
                        let feet = Int(jumpDistanceInches) / 12
                        let inches = Int(jumpDistanceInches) % 12
                        Text("\(feet)'\(String(format: "%02d", inches))\" Jump")
                            .font(.headline)
                        Text("\(jumpScores[Int(jumpDistanceInches), default: 0]) Points")
                            .font(.subheadline)
                    }
                    
                    // Sit Ups
                    VStack(spacing: 3) {
                        Slider(value: $sitUpsCount, in: 0...95, step: 1)
                            .accentColor(.green)
                        Text("\(Int(sitUpsCount)) Sit-ups")
                            .font(.headline)
                        Text("\(sitUpScores[Int(sitUpsCount), default: 0]) Points")
                            .font(.subheadline)
                    }
                    
                    // Push Ups
                    VStack(spacing: 3) {
                        Slider(value: $pushUpsCount, in: 0...72, step: 1)
                            .accentColor(.green)
                        Text("\(Int(pushUpsCount)) Push-ups")
                            .font(.headline)
                        Text("\(pushUpScores[Int(pushUpsCount), default: 0]) Points")
                            .font(.subheadline)
                    }
                    
                    // 600m Run
                    VStack(spacing: 10) {
                        Slider(value: Binding(
                            get: { Double(self.runTimeIndex) },
                            set: { newValue in
                                self.runTimeIndex = min(max(Int(newValue), 0), self.runTimesInSeconds.count - 1)
                            }),
                        in: 0...Double(runTimesInSeconds.count - 1)
                        )
                        .accentColor(.green)
                        
                        let safeRunTimeIndex = min(max(runTimeIndex, 0), runTimesInSeconds.count - 1)
                        let timeInSeconds = runTimesInSeconds[safeRunTimeIndex]
                        let minutes = timeInSeconds / 60
                        let seconds = timeInSeconds % 60
                        
                        Text("\(minutes):\(String(format: "%02d", seconds)) Run")
                            .font(.headline)
                        Text("\(runScores[timeInSeconds, default: 0]) Points")
                            .font(.subheadline)
                    }
                }
                
                // PFT Score display.
                let scoreDetails = gradeAndScale(for: totalScore)
                Text("Male PFT Score: \(totalScore)")
                    .font(.title)
                    .bold()
                    .padding()
                
                Text("Grade: \(scoreDetails.grade)   \(String(format: "%.1f", scoreDetails.pointScale))")
                    .font(.headline)
                    .bold()
                    .padding()
            }
            .padding()
            .foregroundColor(.blue)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MaleScores_Previews: PreviewProvider {
    static var previews: some View {
        MaleScores()
    }
}
