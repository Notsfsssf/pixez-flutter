/*
 * Copyright (C) 2020. by perol_notsf, All rights reserved
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY
 *  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 *  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with
 *  this program. If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:flutter/widgets.dart';

class HeroRadius extends InheritedWidget {
  final BorderRadius radius;

  const HeroRadius({Key? key, required this.radius, required Widget child})
      : super(key: key, child: child);

  static HeroRadius? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroRadius>();

  @override
  bool updateShouldNotify(HeroRadius oldWidget) => oldWidget.radius != radius;
}

class NullHero extends StatelessWidget {
  final String? tag;
  final Widget child;
  final BorderRadius? radius;

  const NullHero({Key? key, this.tag, this.radius, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tag == null) {
      return child;
    }
    final Hero hero = Hero(
      tag: tag!,
      flightShuttleBuilder: radius == null ? null : _radiusShuttle,
      child: child,
    );
    final BorderRadius? r = radius;
    return r == null ? hero : HeroRadius(radius: r, child: hero);
  }
}

Widget _radiusShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final BorderRadius fromRadius =
      HeroRadius.maybeOf(fromHeroContext)?.radius ?? BorderRadius.zero;
  final BorderRadius toRadius =
      HeroRadius.maybeOf(toHeroContext)?.radius ?? BorderRadius.zero;
  final Hero toHero = toHeroContext.widget as Hero;

  final MediaQueryData? toMediaQueryData = MediaQuery.maybeOf(toHeroContext);
  final MediaQueryData? fromMediaQueryData = MediaQuery.maybeOf(fromHeroContext);

  return AnimatedBuilder(
    animation: animation,
    child: toHero.child,
    builder: (BuildContext context, Widget? child) {
      Widget flyingChild = child!;
      if (toMediaQueryData != null && fromMediaQueryData != null) {
        final EdgeInsets fromHeroPadding = fromMediaQueryData.padding;
        final EdgeInsets toHeroPadding = toMediaQueryData.padding;
        flyingChild = MediaQuery(
          data: toMediaQueryData.copyWith(
            padding: (flightDirection == HeroFlightDirection.push)
                ? EdgeInsetsTween(
                    begin: fromHeroPadding,
                    end: toHeroPadding,
                  ).evaluate(animation)
                : EdgeInsetsTween(
                    begin: toHeroPadding,
                    end: fromHeroPadding,
                  ).evaluate(animation),
          ),
          child: child,
        );
      }
      final double t = flightDirection == HeroFlightDirection.push
          ? animation.value
          : 1.0 - animation.value;
      return ClipRRect(
        borderRadius: BorderRadius.lerp(fromRadius, toRadius, t)!,
        child: flyingChild,
      );
    },
  );
}