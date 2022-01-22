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
        case black = 1
        case white
    }
    var turn = turnType.black;
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
    
    override func viewDidLoad() {
        super.viewDidLoad();
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
    
    func checkPiece(_ x: Int, _ y: Int, _ collectionView: UICollectionView? = nil) -> Bool {
        var result = false;
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
                            paths.append(IndexPath(row: (ny-1)*8 + nx-1, section: 0));
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
    
    func changeTurn() {
        turn = turnType(rawValue: 3 - turn.rawValue)!;
        turnLabel.text = turn == .black ? "turn: black" : "turn: white";
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
            changeTurn();
        }
    }
}

extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}

