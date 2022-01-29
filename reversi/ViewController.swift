//
//  ViewController.swift
//  reversi
//
//  Created by Tatsuyoshi Igarashi on 2022/01/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var turnLabel: UILabel! {
        didSet {
            turnLabel.text = turn == .black ? "turn: black" : "turn: white";
        }
    }
    @IBOutlet weak var numberLabel: UILabel! {
        didSet {
            numberLabel.text = "black: 2, white: 2";
        }
    }
    @IBOutlet weak var gameView: UICollectionView! {
        didSet {
            gameView.delegate = self;
            gameView.dataSource = self;
            gameView.collectionViewLayout = {
                let layout = UICollectionViewFlowLayout();
                layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1);
                layout.minimumInteritemSpacing = 0;
                layout.minimumLineSpacing = 1;
                return layout;
            }();
            gameView.backgroundColor = .black;
        }
    }
    
    let cellSize = 40;
    
    enum turnType: Int {
        case none
        case black
        case white
    }
    var turn = turnType.black;
    var comTurn = turnType.none;
    var black = [
        [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 1, 0, 0, 0, -1],
        [-1, 0, 0, 0, 1, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
    ];
    var white = [
        [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 1, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 1, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
    ];
    var enable = [
        [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 1, 0, 0, 0, 0, -1],
        [-1, 0, 0, 1, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 1, 0, 0, -1],
        [-1, 0, 0, 0, 0, 1, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
        [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
    ];
    struct move {
        var x: Int;
        var y: Int;
    }
    struct history {
        var black: [[Int]];
        var white: [[Int]];
        var enable: [[Int]];
        var turn: turnType;
        var recentMove: move;
    }
    var histories: [history] = [];
    
    var blackCount: Int {
        return Array(self.black.joined()).filter({$0 == 1}).count;
    }
    var whiteCount: Int {
        return Array(self.white.joined()).filter({$0 == 1}).count;
    }
    
    lazy var tmpBlack = black;
    lazy var tmpWhite = white;
    lazy var tmpEnable = enable;
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        restartAlert(title: "ようこそ");
    }
    
    func piece(color: UIColor, _ isBorder: Bool) -> UIView {
        let pieceMargin = 2;
        let pieceSize = cellSize - pieceMargin * 2;
        let view = UIView(frame: CGRect(
            x: pieceMargin,
            y: pieceMargin,
            width: pieceSize,
            height: pieceSize
        ));
        view.layer.cornerRadius = CGFloat(pieceSize / 2);
        view.backgroundColor = color;
        if isBorder {
            view.layer.borderWidth = 1;
            view.layer.borderColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 1);
        }
        return view;
    }
    
    func toXY(_ indexPath: IndexPath) -> (Int, Int) {
        (indexPath.row % 8 + 1, indexPath.row / 8 + 1);
    }
    
    func toIndexPath(_ x: Int, _ y: Int) -> IndexPath {
        IndexPath(row: (y-1)*8 + x-1, section: 0);
    }
    
    func reloadNumberLabel() {
        numberLabel.text = "black: \(Array(black.joined()).filter({$0 == 1}).count), white: \(Array(white.joined()).filter({$0 == 1}).count)"
    }
    
    func appendHistory(_ x: Int, _ y: Int) {
        histories.append(history(black: black, white: white, enable: enable, turn: turn, recentMove: move(x: x, y: y)));
    }
    
    func getBoard(_ turn: turnType) -> ([[Int]], [[Int]]) {
        turn == .black ? (black, white) : (white, black);
    }
    
    struct enableMoveInfo {
        var isEnabled: Bool;
        var paths: [IndexPath];
        var enable: [[Int]];
    }
    
    func checkEnbleFlip(_ myBoard: [[Int]], _ yourBoard: [[Int]]) -> enableMoveInfo {
        var info = enableMoveInfo(isEnabled: false, paths: [], enable: [
            [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
            [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
            [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
            [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
            [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
            [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
            [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
            [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
            [-1, 0, 0, 0, 0, 0, 0, 0, 0, -1],
            [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
        ]);
        for y in 1 ..< 9 {
            for x in 1 ..< 9 {
                let pieceInfo = checkPiece(x, y, myBoard: myBoard, yourBoard: yourBoard);
                if pieceInfo.isEnabled {
                    info.enable[y][x] = 1;
                    info.paths.append(toIndexPath(x, y));
                    info.isEnabled = true;
                } else if enable[y][x] == 1 {
                    info.enable[y][x] = 0;
                    info.paths.append(toIndexPath(x, y));
                }
            }
        }
        return info;
    }
    
    struct moveInfo {
        var x: Int;
        var y: Int;
        var isEnabled: Bool;
        var paths: [IndexPath];
        var myBoard: [[Int]];
        var yourBoard: [[Int]];
    }
    func checkPiece(_ x: Int, _ y: Int, myBoard: [[Int]], yourBoard: [[Int]]) -> moveInfo {
        var result = moveInfo(x: x, y: y, isEnabled: false, paths: [], myBoard: myBoard, yourBoard: yourBoard);
        guard myBoard[y][x] == 0 && yourBoard[y][x] == 0 else { return result }
        for dy in -1 ... 1 {
            for dx in -1 ... 1 {
                if dy == 0 && dx == 0 { continue };
                var _piece = 0;
                var ny = y + dy, nx = x + dx;
                if yourBoard[ny][nx] == 1 {
                    var isMyPiece = false;
                    while !isMyPiece && _piece != -1 {
                        ny = ny + dy;
                        nx = nx + dx;
                        _piece = yourBoard[ny][nx];
                        if myBoard[ny][nx] == 1 {
                            isMyPiece = true;
                            result.isEnabled = true;
                        } else if myBoard[ny][nx] == 0 && yourBoard[ny][nx] == 0 {
                            break;
                        }
                    }
                    if isMyPiece {
                        while !(y == ny && x == nx) {
                            ny = ny - dy;
                            nx = nx - dx;
                            result.myBoard[ny][nx] = 1;
                            result.yourBoard[ny][nx] = 0;
                            result.paths.append(toIndexPath(nx, ny));
                        }
                    }
                }
            }
        }
        return result;
    }
    
    func flipPiece(info: moveInfo) {
        if turn == .black {
            black = info.myBoard;
            white = info.yourBoard;
        } else {
            black = info.yourBoard;
            white = info.myBoard;
        }
        var paths = info.paths;
        if paths.count > 0 {
            paths.append(toIndexPath(histories.last?.recentMove.x ?? 0, histories.last?.recentMove.y ?? 0));
            appendHistory(info.x, info.y);
            reloadNumberLabel();
            gameView.reloadItems(at: paths);
        }
        changeTurn(gameView);
    }
    
    func flip(_ x: Int, _ y: Int, myBoard: [[Int]], yourBoard: [[Int]]) -> ([[Int]], [[Int]]) {
        var result = (myBoard: myBoard, yourBoard: yourBoard);
        if white[y][x] == 1 || black[y][x] == 1 { print("error: L192");return result }
        for dy in -1 ... 1 {
            for dx in -1 ... 1 {
                if dy == 0 && dx == 0 { continue };
                var _piece = 0;
                var ny = y + dy, nx = x + dx;
                if yourBoard[ny][nx] == 1 {
                    var isMyPiece = false;
                    while !isMyPiece && _piece != -1 {
                        ny = ny + dy;
                        nx = nx + dx;
                        _piece = yourBoard[ny][nx];
                        if myBoard[ny][nx] == 1 {
                            isMyPiece = true;
                        } else if myBoard[ny][nx] == 0 && yourBoard[ny][nx] == 0 {
                            break;
                        }
                    }
                    if isMyPiece {
                        while !(y == ny && x == nx) {
                            ny = ny - dy;
                            nx = nx - dx;
                            result.myBoard[ny][nx] = 1;
                            result.yourBoard[ny][nx] = 0;
                        }
                    }
                }
            }
        }
        return result;
    }
    
    struct monteCarloResult {
        var turn: turnType;
        var x: Int;
        var y: Int;
        var black: [[Int]];
        var white: [[Int]];
    }
    func monteCarlo(firstX: Int = -1, firstY: Int = -1, myBoard: [[Int]], yourBoard: [[Int]], _ turn: turnType, didSkip: Bool = false) -> monteCarloResult {
        var x = 0, y = 0;
        let enableInfo = checkEnbleFlip(myBoard, yourBoard);
        guard enableInfo.isEnabled else {
            if didSkip {
                let (black, white) = turn == .black ? (myBoard, yourBoard) : (yourBoard, myBoard);
                return monteCarloResult(turn: turn, x: firstX, y: firstY, black: black, white: white);
            } else {
                return monteCarlo(firstX: firstX, firstY: firstY, myBoard: yourBoard, yourBoard: myBoard, turnType(rawValue: 3 - turn.rawValue)!, didSkip: true);
            }
        }
        while true {
            x = Int.random(in: 1...8);
            y = Int.random(in: 1...8);
            if enableInfo.enable[y][x] == 1 { break }
        }
        let flipInfo = checkPiece(x, y, myBoard: myBoard, yourBoard: yourBoard);
        let fx = firstX == -1 ? x : firstX, fy = firstY == -1 ? y : firstY;
        return monteCarlo(firstX: fx, firstY: fy, myBoard: flipInfo.yourBoard, yourBoard: flipInfo.myBoard, turnType(rawValue: 3 - turn.rawValue)!);
    }
    
    func ai() -> (x: Int, y: Int, w: Double) {
        let (myBoard, yourBoard) = getBoard(comTurn);
        var max = (x: 0, y: 0, w: -1.0);
        guard checkEnbleFlip(myBoard, yourBoard).isEnabled else { return max }
        var results = [[Double]](repeating: [Double](repeating: 0, count: 9), count: 9);
        for _ in 0...99 {
            let result = monteCarlo(myBoard: myBoard, yourBoard: yourBoard, comTurn);
            var w = 0.0;
            let blackCount = Array(result.black.joined()).filter({$0 == 1}).count,
                whiteCount = Array(result.white.joined()).filter({$0 == 1}).count;
            if blackCount > whiteCount {
                w = comTurn == .black ? 1 : 0;
            } else if whiteCount > blackCount {
                w = comTurn == .white ? 1 : 0;
            } else {
                w = 0.5;
            }
            results[result.y][result.x] = results[result.y][result.x] + w;
        }
        for (y, result) in results.enumerated() {
            for (x, w) in result.enumerated() {
                if w > max.w {
                    max = (x: x, y: y, w: w);
                }
            }
        }
        print(max);
        print(checkPiece(max.x, max.y, myBoard: myBoard, yourBoard: yourBoard));
        return max;
    }
    
    func asyncAI() {
        let (myBoard, yourBoard) = getBoard(turn);
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.async {
            let result = self.ai();
            let queue = DispatchQueue.main
            queue.async {
                if result.w == -1 {
                    self.changeTurn(self.gameView, didPrevTurnDisabled: true);
                } else {
                    let info = self.checkPiece(result.x, result.y, myBoard: myBoard, yourBoard: yourBoard);
                    self.flipPiece(info: info);
                }
            }
        }
    }
    
    func boardInit(comTurn: turnType = .none) {
        turn = .black;
        self.comTurn = comTurn;
        black = tmpBlack;
        white = tmpWhite;
        enable = tmpEnable;
        histories.removeAll();
        histories.append(history(black: black, white: white, enable: enable, turn: turn, recentMove: move(x: -1, y: -1)));
        gameView.reloadData();
    }
    
    func restartAlert(title: String) {
        let alertController:UIAlertController = UIAlertController(title: title, message: "モードを選択してください", preferredStyle: .alert)
        let p2pAction:UIAlertAction = UIAlertAction(title: "対人戦でプレイ", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            self.boardInit()
        })
        let p2comAction:UIAlertAction =
        UIAlertAction(title: "黒番でプレイ",
                      style: .default,
                      handler:{
            (action:UIAlertAction!) -> Void in
            self.boardInit(comTurn: .white)
        })
        let com2pAction:UIAlertAction =
        UIAlertAction(title: "白番でプレイ",
                      style: .default,
                      handler:{
            (action:UIAlertAction!) -> Void in
            self.boardInit(comTurn: .black);
            self.asyncAI();
        })
        
        alertController.addAction(p2pAction);
        alertController.addAction(p2comAction);
        alertController.addAction(com2pAction);
        
        present(alertController, animated: true, completion: nil);
    }
    
    func changeTurn(_ collectionView: UICollectionView, didPrevTurnDisabled: Bool = false) {
        turn = turnType(rawValue: 3 - turn.rawValue)!;
        let (myBoard, yourBoard) = getBoard(turn);
        let info = checkEnbleFlip(myBoard, yourBoard);
        if info.isEnabled {
            enable = info.enable;
            collectionView.reloadItems(at: info.paths);
        } else {
            if didPrevTurnDisabled {
                if blackCount > whiteCount {
                    restartAlert(title: "黒番の勝ち！");
                } else if blackCount < whiteCount {
                    restartAlert(title: "白番の勝ち！");
                } else {
                    restartAlert(title: "引き分け！");
                }
            } else {
                changeTurn(collectionView, didPrevTurnDisabled: true);
            }
        }
        turnLabel.text = turn == .black ? "turn: black" : "turn: white";
        if turn == comTurn {
            asyncAI();
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 64
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let (x, y) = toXY(indexPath);
        let isBorder = histories.last?.recentMove.x == x && histories.last?.recentMove.y == y;
        cell.subviews.forEach({ $0.removeFromSuperview()});
        cell.backgroundColor = UIColor(72, 93, 63, 1);
        if black[y][x] == 1 {
            cell.addSubview(piece(color: .black, isBorder));
        } else if white[y][x] == 1 {
            cell.addSubview(piece(color: .white, isBorder));
        } else if enable[y][x] == 1 {
            cell.addSubview(piece(color: UIColor(90, 255, 25, 1), isBorder));
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize);
    }
}


extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard turn != comTurn else { return }
        let (x, y) = toXY(indexPath);
        let (myBoard, yourBoard) = getBoard(turn);
        let info = checkPiece(x, y, myBoard: myBoard, yourBoard: yourBoard);
        if info.isEnabled {
            flipPiece(info: info);
        }
    }
}

extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}

