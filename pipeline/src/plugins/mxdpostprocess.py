"""Module for post-processing functionality."""

# """Prototype postprocessing."""
from ctypes import Union
from typing import Optional, Tuple, List

import numpy as np
from pydantic import BaseModel
import cv2

import data_science
from gstreamer import Gst, GObject, GLib, GstBase, gst_buffer_to_ndarray  # noqa

from clearobject.i7e.deepstream.plugins.postprocess.gst_post_process import (
    Inferences,
    PostProcessResult,
    GstPostProcess,
)
from data_science import post_proc, genericResult


class genericPostProcess(GstPostProcess):
    """Postprocessing plugin."""

    def post_process(
        self,
        inferences: Inferences,
        original_image: Optional[np.ndarray],
    ) -> Tuple[PostProcessResult, np.ndarray]:

        seg = inferences.segmentation.segmentation_mask
        result, verbose, seg_result = post_proc(seg, original_image)
        seg_result.fps = inferences.fps
        image = data_science.visualize(result, verbose, original_image)
        return seg_result, image

    def retrieve_segmentation(self, ptr):
        """Overrides function in post_proc, some proc steps before DS code"""

        v: np.ndarray = np.ctypeslib.as_array(
            ptr,
            shape=(self.width * self.height * 4,),
        )
        v = v.reshape(
            (
                self.width,
                self.height,
                4,
            )
        ).round()
        return v

    def flatten_results(
        self,
        results: genericResult,
    ) -> genericResult:
        """Nothing to do here."""
        return results


GObject.type_register(genericPostProcess)
__gstelementfactory__ = (genericPostProcess.GST_PLUGIN_NAME, Gst.Rank.NONE, genericPostProcess)
