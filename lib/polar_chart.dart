import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Paints a Polar Plot using the given data
/// [circleDivisions] are the divisions of radius between the center and circle border
/// make sure that the last element of the list is the maximum individual number/score
/// of the datapoints too DEFAULT: [100]
///
///
/// [labels] are the labels of the plotting data factor/labels
///
///
/// [dataPoints] is the list of data of individual entity containing
/// the same number of dataPoints as the number of labels
///
///
/// [labelsTextStyle] is the textStyle for label text being painted
///
///
/// [borderColor] is circle of the border of the circle:
/// DEFAULT: Grey (0xffa6a5a4)
///
///
/// [circleDivisionsColor] is color of the divisional lines
/// in the plot: DEFAULT: Grey (0xffa6a5a4)
///
///
/// [dataGraphColors] colors for the plotted graph it shows a
/// gradient based on the color passed and iterates through
/// the number of colors for further dataPoints
/// DEFAULT: [Colors.orange, Colors.green, Colors.blue, Colors.yellow]
///
///
/// [dataGraphscaler] is a factor between 0.0 to 1.0 that scales
/// the internal graph from small to correct size used only for
/// animation purposes: DEFAULT : 1.0
class PolarChartPainter extends CustomPainter {
  final List<int> circleDivisions;
  final List<String> labels;
  final List<List<int>> dataPoints;
  final TextStyle labelsTextStyle;
  final Color borderColor;
  final Color circleDivisionsColor;
  final List<Color> dataGraphColors;
  final double dataGraphscaler;

  const PolarChartPainter({
    this.circleDivisions = const [100],
    required this.labels,
    required this.dataPoints,
    this.labelsTextStyle = const TextStyle(
      color: Colors.black54,
      fontSize: 10,
    ),
    this.borderColor = const Color(0xffa6a5a4),
    this.circleDivisionsColor = const Color(0xffa6a5a4),
    this.dataGraphColors = const [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.yellow
    ],
    this.dataGraphscaler = 1.0,
  });

  ///function for return a circular Path of [center] and [radius]
  Path _circlePath(Offset center, double radius) {
    var path = Path();
    // creating a circle from a bounded rectangle
    path.addOval(Rect.fromCircle(
      center: center,
      radius: radius,
    ));
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerOffset = Offset(size.width / 2.0, size.height / 2.0);
    final radius = math.min(centerOffset.dx, centerOffset.dy) * 0.8;

    //scale factor for radius from the circleDivision's last element
    //i.e considering [10,20,100] as divisions and radius to be 200
    // then factor will be 2 ( 200(radius) / 100(last division) )
    final radiusScaleResponsiveFactor = radius / circleDivisions.last;

    //paint object for drawing circular border of polar plot
    var borderPaintStyle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = borderColor;

    //outer border of circle of polar plot
    canvas.drawPath(_circlePath(centerOffset, radius), borderPaintStyle);

    //paint object for drawing inner divisions in the circle of polar plot
    var circleDivisionsPaintStyle = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = circleDivisionsColor;
    //inner division circles with respect to scale factor of radius
    //for each division
    circleDivisions.asMap().forEach((index, division) {
      if (index == circleDivisions.length - 1) return null;
      var divisionRadius = division * radiusScaleResponsiveFactor;
      canvas.drawPath(
          _circlePath(centerOffset, divisionRadius), circleDivisionsPaintStyle);
    });

    // calculating angle between 2 labels
    // by formula (2π / length of the list of labels)
    var angle = (2 * math.pi) / labels.length;

    //creating label straight divisional lines
    labels.asMap().forEach((index, label) {
      // factor of offset from center to the angle along the x axis
      //               -1 ------------0----------- 1 (x-axis)
      //  (negative) offset         center       offset (positive)
      // by cosine we get offset of x- axis
      var xOffsetFactorOfPoint = math.cos(angle * index - math.pi / 2);

      // factor of offset from center to the angle along the y axis
      //                               -1 (negative offset)
      //                               |
      //                               |
      //                               0  center
      //                               |
      //                               |
      //                               1 (positive offset)
      //                            y- axis
      // by sine we get offset of y-axis
      var yOffsetFactorOfPoint = math.sin(angle * index - math.pi / 2);

      //calculating co-ordinates of the point on the border
      //for the label from the offset
      // for example if the point is on (100,150)
      // then radius being 200 and center been at 100,100 then
      // x cordinate will be (100+ 200) * xOffsetFactor i.e 1/3 approx. 70 degree from x-axis
      // y cordinate will be (100+ 200) * yoffsetFactor i.e 1/2 approx  30 degree from y-axis
      var labelOffset = Offset(centerOffset.dx + radius * xOffsetFactorOfPoint,
          centerOffset.dy + radius * yOffsetFactorOfPoint);
      Offset labelTextOffset;
      double labelYOffset;
      double labelXOffset;

      //same as for co-ordinate but only adding 10 to radius for the
      //padding between the text and border point
      labelTextOffset = Offset(
          centerOffset.dx + (radius + 10) * xOffsetFactorOfPoint,
          centerOffset.dy + (radius + 10) * yOffsetFactorOfPoint);
      //if label is perpendicular to x-axis
      print('index: $index, xoffset: $xOffsetFactorOfPoint');

      // drawing the text label for each label using label offsets with paddings
      final labelPainter = TextPainter(
        text: TextSpan(text: label, style: labelsTextStyle),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: size.width);
      //if xoffset is equal to 0 i.e either is perpendicular to x-axis
      if (xOffsetFactorOfPoint == math.cos(-math.pi / 2)) {
        // push the label to left by 10
        labelXOffset = xOffsetFactorOfPoint - (labelPainter.size.width / 2);
        // if it's on positive part of y-axis then add 15 more padding towards down
        // if it's on negative part of x-axis then add 25 more padding towards up i.e -25
        labelYOffset = yOffsetFactorOfPoint == -1
            ? yOffsetFactorOfPoint - 15
            : yOffsetFactorOfPoint + 5;
      }
      //if xoffset is 1 or -1 i.e perpendicular to y-axis
      else if (xOffsetFactorOfPoint == 1 || xOffsetFactorOfPoint == -1) {
        labelYOffset = yOffsetFactorOfPoint - (labelPainter.size.height / 2);
        labelXOffset = xOffsetFactorOfPoint == -1
            ? -labelPainter.size.width
            : xOffsetFactorOfPoint;
      } else {
        //a slight up  shift of label based on whether the label is in upward
        //part of x-axis or lower side of x-axis
        labelYOffset = yOffsetFactorOfPoint < 0 ? -8 : -2;

        //left as width of text shift or right shift of label based on whether the label is in upward
        //part of x-axis or lower side of x-axis
        labelXOffset = xOffsetFactorOfPoint < 0 ? -labelPainter.width : 0;
      }
      // drawing the line from center to the label point
      canvas.drawLine(centerOffset, labelOffset, circleDivisionsPaintStyle);

      labelPainter.paint(
        canvas,
        Offset(
          labelTextOffset.dx + labelXOffset,
          labelTextOffset.dy + labelYOffset,
        ),
      );
    });

    // Painting each plotData
    dataPoints.asMap().forEach((index, plotData) {
      var plotPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            dataGraphColors[index % dataGraphColors.length].withOpacity(0.3),
            dataGraphColors[index % dataGraphColors.length].withOpacity(0.6),
          ],
        ).createShader(Rect.fromCircle(center: centerOffset, radius: radius))
        ..style = PaintingStyle.fill;

      // scaledPoint is the responsive point by scaling radius factor
      // which is calculated using the first initial point from the plotData
      //graph scaler is used for animation purposes with point being between 0.0 to 1.0
      var scaledPoint =
          radiusScaleResponsiveFactor * plotData[0] * dataGraphscaler;
      //since the first point is ploted on the perpendicular line onto the x-axis the
      //x coordinate will be center itself and y will be center - point since point
      //is in upward direction
      var path = Path()..moveTo(centerOffset.dx, centerOffset.dy - scaledPoint);
      plotData.asMap().forEach((index, point) {
        if (index == 0) return;
        //following the same concept used while plotting label points
        var xOffsetFactor = math.cos(angle * index - math.pi / 2);
        var yOffsetFactor = math.sin(angle * index - math.pi / 2);
        var scaledPoint = radiusScaleResponsiveFactor * point * dataGraphscaler;
        path.lineTo(centerOffset.dx + scaledPoint * xOffsetFactor,
            centerOffset.dy + scaledPoint * yOffsetFactor);
      });
      //close the path for filling it
      path.close();

      canvas.drawPath(path, plotPaint);
    });
  }

  @override
  bool shouldRepaint(PolarChartPainter oldDelegate) {
    //only repaint if the graphScaler changes for animation purposes
    return oldDelegate.dataGraphscaler != dataGraphscaler;
  }
}
