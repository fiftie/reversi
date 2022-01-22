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
    
    func piece(color: UIColor) -> UIView {
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
        return view;
    }
    
    func toXY(_ indexPath: IndexPath) -> (Int, Int) {
        (indexPath.row % 8 + 1, indexPath.row / 8 + 1);
    }
    
    func toIndexPath(_ x: Int, _ y: Int) -> IndexPath {
        IndexPath(row: (y-1)*8 + x-1, section: 0);
    }
    
    func checkPiece(_ x: Int, _ y: Int, _ collectionView: UICollectionView? = nil) -> Bool {
        var result = false;
        if white[y][x] == 1 || black[y][x] == 1 { return result }
        // TODO: use UnsafeBufferPointer
        let (myBoard, yourBoard): (UnsafeMutablePointer<[Int]>, UnsafeMutablePointer<[Int]>) = turn == .black ? (.init(&black), .init(&white)) : (.init(&white), .init(&black));
        var paths: [IndexPath] = [];
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
                            result = true;
                        }
                    }
                    if isMyPiece && collectionView != nil {
                        while !(y == ny && x == nx) {
                            ny = ny - dy;
                            nx = nx - dx;
                            myBoard[ny][nx] = 1;
                            yourBoard[ny][nx] = 0;
                            paths.append(toIndexPath(nx, ny));
                        }
                    }
                }
            }
        }
        if collectionView != nil {
            collectionView?.reloadItems(at: paths);
            numberLabel.text = "black: \(Array(black.joined()).filter({$0 == 1}).count), white: \(Array(white.joined()).filter({$0 == 1}).count)"
        }
        return result;
    }
    
    func ai(_ collectionView: UICollectionView) {
        var flip = (x: 0, y: 0, i: 0);
        for y in 1 ..< 9 {
            for x in 1 ..< 9 {
                if white[y][x] == 1 || black[y][x] == 1 { continue }
                let (myBoard, yourBoard) = turn == .black ? (black, white) : (white, black);
                for dy in -1 ... 1 {
                    for dx in -1 ... 1 {
                        if dy == 0 && dx == 0 { continue };
                        var _piece = 0;
                        var i = 0;
                        var ny = y + dy, nx = x + dx;
                        if yourBoard[ny][nx] == 1 {
                            var isMyPiece = false;
                            while !isMyPiece && _piece != -1 {
                                ny = ny + dy;
                                nx = nx + dx;
                                i = i + 1;
                                _piece = yourBoard[ny][nx];
                                if myBoard[ny][nx] == 1 {
                                    if i > flip.i {
                                        flip = (x: x, y: y, i: i);
                                    }
                                    isMyPiece = true;
                                }
                            }
                        }
                    }
                }
            }
        }
        let _ = checkPiece(flip.x, flip.y, collectionView);
        changeTurn(collectionView);
    }
    
    func boardInit(comTurn: turnType = .none) {
        turn = .black;
        self.comTurn = comTurn;
        black = tmpBlack;
        white = tmpWhite;
        enable = tmpEnable;
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
            self.ai(self.gameView);
        })
        
        alertController.addAction(p2pAction);
        alertController.addAction(p2comAction);
        alertController.addAction(com2pAction);
        
        present(alertController, animated: true, completion: nil);
    }
    
    func changeTurn(_ collectionView: UICollectionView, didPrevTurnDisabled: Bool = false) {
        turn = turnType(rawValue: 3 - turn.rawValue)!;
        var paths: [IndexPath] = [];
        var isEnabled = false;
        for y in 1 ..< 9 {
            for x in 1 ..< 9 {
                if checkPiece(x, y) {
                    enable[y][x] = 1;
                    paths.append(toIndexPath(x, y));
                    isEnabled = true;
                } else if enable[y][x] == 1 {
                    enable[y][x] = 0;
                    paths.append(toIndexPath(x, y));
                }
            }
        }
        if isEnabled {
            collectionView.reloadItems(at: paths);
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
            ai(collectionView);
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
        cell.subviews.forEach({ $0.removeFromSuperview()});
        cell.backgroundColor = UIColor(72, 93, 63, 1);
        if black[y][x] == 1 {
            cell.addSubview(piece(color: .black));
        } else if white[y][x] == 1 {
            cell.addSubview(piece(color: .white));
        } else if enable[y][x] == 1 {
            cell.addSubview(piece(color: UIColor(90, 255, 25, 1)));
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
        let (x, y) = toXY(indexPath);
        if checkPiece(x, y, collectionView) {
            changeTurn(collectionView);
        }
    }
}

extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}

