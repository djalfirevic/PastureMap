//
//  HomeViewController.swift
//  PastureMap
//
//  Created by Djuro Alfirevic on 3/9/18.
//  Copyright © 2018 Djuro Alfirevic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var drawBarButtonItem: UIBarButtonItem!
    var lastPoint = CGPoint.zero
    var swiped = false
    var coordinates = [CLLocationCoordinate2D]()
    var polyline = MKPolyline()
    let lineWidth: CGFloat = 3.0
    var isDrawing = false
    
    // MARK: - Actions
    @IBAction func drawButtonTapped() {
        if drawBarButtonItem.title == Buttons.draw {
            mapView.isUserInteractionEnabled = false
            drawBarButtonItem.title = Buttons.stop
        } else {
            mapView.isUserInteractionEnabled = true
            drawBarButtonItem.title = Buttons.draw
            isDrawing = false
            drawPolyline()
        }
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if mapView.point(inside: touch.location(in: mapView), with: event) {
                isDrawing = true
                swiped = false
                lastPoint = touch.location(in: mapView)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDrawing { return }
        
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: mapView)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDrawing { return }
        
        if !swiped {
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        isDrawing = false
        drawPolyline()
    }
    
    // MARK: - Private API
    fileprivate func configureMap() {
        mapView.mapType = .satellite
        
        if let polylines = DataManager.shared.getPolylines() {
            mapView.addOverlays(polylines)
        }
    }
    
    fileprivate func drawLineFrom(_ point: CGPoint, toPoint: CGPoint) {
        coordinates.append(mapView.convert(point, toCoordinateFrom: mapView))
        coordinates.append(mapView.convert(toPoint, toCoordinateFrom: mapView))
    }

    fileprivate func drawPolyline() {
        if !coordinates.isEmpty {
            polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.add(polyline)
            
            askUserToSavePasture()
        }
    }
    
    fileprivate func askUserToSavePasture() {
        guard !coordinates.isEmpty else { return }
        
        let alertController = UIAlertController(title: Titles.pasture, message: Messages.savePastureQuestion, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = Placeholders.pastureName
        }
        
        let noAction = UIAlertAction(title: Buttons.no, style: .cancel) { (actions) in
            self.coordinates.removeAll()
            self.drawButtonTapped()
        }
        alertController.addAction(noAction)
        
        let yesAction = UIAlertAction(title: Buttons.yes, style: .default) { (action) in
            if let textField = alertController.textFields?.first {
                if let text = textField.text {
                    DataManager.shared.savePasture(with: text, coordinates: self.coordinates)
                    self.coordinates.removeAll()
                    self.drawButtonTapped()
                }
            }
        }
        alertController.addAction(yesAction)
        
        present(alertController, animated: true)
    }
    
}

extension HomeViewController: MKMapViewDelegate {
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.red
            return renderer
        }
        
        return MKOverlayRenderer()
    }
    
}
