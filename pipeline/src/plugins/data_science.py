"""Code largely maintained by Data Science team."""

from itertools import count
import os.path

import functools
import logging
from threading import Lock
from typing import List, Tuple, Optional
import time

import numpy as np
import nvtx
from pydantic import Field, BaseModel, ConfigDict
import cv2
import yaml
from PIL import ImageFont, ImageDraw, Image
from clearobject.i7e.deepstream.plugins.postprocess.gst_post_process import PostProcessResult

logger = logging.getLogger("POSTPROCESS.DATA_SCIENCE")

class genericResult(PostProcessResult):
    """Segmentation result with detailed object information."""
    class_name: str = Field(alias="className")
    class_id: int = Field(alias="classId")
    confidence: float = Field(alias="confidence")
    bbox: Tuple[int, int, int, int] = Field(alias="bbox")


def pre_process(image, width, height, element_index) -> np.ndarray:
    """Processing before segmentation"""
    
    return image

def post_proc(
    segmentation: np.ndarray,
    original_image: np.ndarray,
):
    """Post Processing."""
    segmentation = segmentation.squeeze().round()
    segmentation = cv2.resize(segmentation, (original_image.shape[1], original_image.shape[0]))
    segmentation_result = genericResult()

    return segmentation_result
