//
//  MapMbTile.js
//  AirMaps
//
//  Created by Christoph Lambio on 27/03/2018.
//  Based on AIRMapLocalTileManager.h
//

import PropTypes from 'prop-types';
import React from 'react';

import {
  ViewPropTypes,
  View,
} from 'react-native';

import decorateMapComponent, {
  USES_DEFAULT_IMPLEMENTATION,
  SUPPORTED,
} from './decorateMapComponent';

// if ViewPropTypes is not defined fall back to View.propType (to support RN < 0.44)
const viewPropTypes = ViewPropTypes || View.propTypes;

const propTypes = {
  ...viewPropTypes,

  /**
   * The path template of the MBTiles database tile source.
   * The patterns {x} {y} {z} will be replaced at runtime,
   * for example, /storage/emulated/0/tiles/{z}/{x}/{y}.png.
   */
  pathTemplate: PropTypes.string.isRequired,

  /**
   * The order in which this tile overlay is drawn with respect to other overlays. An overlay
   * with a larger z-index is drawn over overlays with smaller z-indices. The order of overlays
   * with the same z-index is arbitrary. The default zIndex is -1.
   *
   * @platform android
   */
  zIndex: PropTypes.number,

  /**
   * Size of tile images.
   */
  tileSize: PropTypes.number,

  /**
   * Specification for the structure of the tiles.
   * Currently XYZ and TMS are supported 
   * XYZ: https://en.wikipedia.org/wiki/Tiled_web_map
   * TMS: http://wiki.osgeo.org/wiki/Tile_Map_Service_Specification
   */
  tileSpecification: PropTypes.string,
};

class MapMbTile extends React.Component {
  render() {
    const AIRMapMbTile = this.getAirComponent();
    return (
      <AIRMapMbTile
        {...this.props}
      />
    );
  }
}

MapMbTile.propTypes = propTypes;

export default decorateMapComponent(MapMbTile, {
  componentType: 'MbTile',
  providers: {
    google: {
      ios: SUPPORTED,
      android: USES_DEFAULT_IMPLEMENTATION,
    },
  },
});
