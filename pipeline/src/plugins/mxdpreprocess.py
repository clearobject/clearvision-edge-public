"""Module for pre-processing functionality."""

# """Prototype preprocessing."""

import numpy as np

import data_science
from clearobject.i7e.deepstream.plugins.preprocess import (
    SINK_CAPS,
    SRC_CAPS,
    GstPreProcess,
    GObject,
    Gst,
)

SINK_CAPS = SINK_CAPS
SRC_CAPS = SRC_CAPS

class genericpreprocess(GstPreProcess):
    def pre_process(
            self,
            image: np.ndarray,
            element_index: int = 0,
        ) -> np.ndarray:
            """Processing before inference"""
            return data_science.pre_process(image, self.width, self.height, element_index)


# Make plugin available as "preprocess"
GObject.type_register(genericpreprocess)
__gstelementfactory__ = (genericpreprocess.GST_PLUGIN_NAME, Gst.Rank.NONE, genericpreprocess)
