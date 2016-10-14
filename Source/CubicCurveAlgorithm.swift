//
//  CubicCurveAlgorithm.swift
//  Bezier
//
//  Created by Ramsundar Shandilya on 10/12/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import Foundation
import UIKit

struct CubicCurveSegment
{
  let controlPoint1: CGPoint
  let controlPoint2: CGPoint
}

class CubicCurveAlgorithm
{
  fileprivate var firstControlPoints: [CGPoint?] = []
  fileprivate var secondControlPoints: [CGPoint?] = []
  
  func controlPointsFromPoints(_ dataPoints: [CGPoint]) -> [CubicCurveSegment] {
    
    //Number of Segments
    let count = dataPoints.count - 1
    
    //P0, P1, P2, P3 are the points for each segment, where P0 & P3 are the knots and P1, P2 are the control points.
    if count == 1 {
      let P0 = dataPoints[0]
      let P3 = dataPoints[1]
      
      //Calculate First Control Point
      //3P1 = 2P0 + P3
      
      let P1x = (2*P0.x + P3.x)/3
      let P1y = (2*P0.y + P3.y)/3
      
      firstControlPoints.append(CGPoint(x: P1x, y: P1y))
      
      //Calculate second Control Point
      //P2 = 2P1 - P0
      let P2x = (2*P1x - P0.x)
      let P2y = (2*P1y - P0.y)
      
      secondControlPoints.append(CGPoint(x: P2x, y: P2y))
    } else {
      firstControlPoints = Array(repeating: nil, count: count)
      
      var rhsArray = [CGPoint]()
      
      //Array of Coefficients
      var a = [Double]()
      var b = [Double]()
      var c = [Double]()
      
      for i in 0 ..< count {
        
        var rhsValueX: CGFloat = 0
        var rhsValueY: CGFloat = 0
        
        let P0 = dataPoints[i];
        let P3 = dataPoints[i+1];
        
        if i==0 {
          a.append(0)
          b.append(2)
          c.append(1)
          
          //rhs for first segment
          rhsValueX = P0.x + 2*P3.x;
          rhsValueY = P0.y + 2*P3.y;
          
        } else if i == count-1 {
          a.append(2)
          b.append(7)
          c.append(0)
          
          //rhs for last segment
          rhsValueX = 8*P0.x + P3.x;
          rhsValueY = 8*P0.y + P3.y;
        } else {
          a.append(1)
          b.append(4)
          c.append(1)
          
          rhsValueX = 4*P0.x + 2*P3.x;
          rhsValueY = 4*P0.y + 2*P3.y;
        }
        
        rhsArray.append(CGPoint(x: rhsValueX, y: rhsValueY))
      }
      
      //Solve Ax=B. Use Tridiagonal matrix algorithm a.k.a Thomas Algorithm
      
      for i in 1 ..< count {
        let rhsValueX = rhsArray[i].x
        let rhsValueY = rhsArray[i].y
        
        let prevRhsValueX = rhsArray[i-1].x
        let prevRhsValueY = rhsArray[i-1].y
        
        let m = a[i]/b[i-1]
        
        let b1 = b[i] - m * c[i-1];
        b[i] = b1
        
        let r2x = rhsValueX.f - m * prevRhsValueX.f
        let r2y = rhsValueY.f - m * prevRhsValueY.f
        
        rhsArray[i] = CGPoint(x: r2x, y: r2y)
        
      }
      
      //Get First Control Points
      
      //Last control Point
      let lastControlPointX = rhsArray[count-1].x.f/b[count-1]
      let lastControlPointY = rhsArray[count-1].y.f/b[count-1]
      
      firstControlPoints[count-1] = CGPoint(x: lastControlPointX, y: lastControlPointY)
      
      
      let total = count - 2
      for i in (0...total).reversed() {
        if let nextControlPoint = firstControlPoints[i+1] {
          let controlPointX = (rhsArray[i].x.f - c[i] * nextControlPoint.x.f)/b[i]
          let controlPointY = (rhsArray[i].y.f - c[i] * nextControlPoint.y.f)/b[i]
          
          firstControlPoints[i] = CGPoint(x: controlPointX, y: controlPointY)
          
        }
      }
      
      //Compute second Control Points from first
      
      for i in 0 ..< count {
        
        if i == count-1 {
          let P3 = dataPoints[i+1]
          
          guard let P1 = firstControlPoints[i] else{
            continue
          }
          
          let controlPointX = (P3.x + P1.x)/2
          let controlPointY = (P3.y + P1.y)/2
          
          secondControlPoints.append(CGPoint(x: controlPointX, y: controlPointY))
          
        } else {
          let P3 = dataPoints[i+1]
          
          guard let nextP1 = firstControlPoints[i+1] else {
            continue
          }
          
          let controlPointX = 2*P3.x - nextP1.x
          let controlPointY = 2*P3.y - nextP1.y
          
          secondControlPoints.append(CGPoint(x: controlPointX, y: controlPointY))
        }
      }
    }
    
    var controlPoints = [CubicCurveSegment]()
    
    for i in 0 ..< count {
      if let firstControlPoint = firstControlPoints[i],
        let secondControlPoint = secondControlPoints[i] {
        let segment = CubicCurveSegment(controlPoint1: firstControlPoint, controlPoint2: secondControlPoint)
        controlPoints.append(segment)
      }
    }
    
    return controlPoints
  }
}

extension CGFloat {
  var f: Double {
    return Double(self)
  }
}
