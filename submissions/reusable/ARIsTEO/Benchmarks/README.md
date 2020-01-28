This folder contains the benchmarks that are considered in our study.
Specifically:

RHB - Room Heating Benchmark - RHB(1) and RHB(2)
Controls the transfer of heaters among adjacent rooms to maintain the temperature of the rooms within a desired range. In the RHB(1) version the input of the system is the outside temperature. In the RHB(2) version errors in the input measures are also considered. The goal is to find a profile of the outside temperature, s.t., the controller is not able to maintain the temperature within the desired range in the rooms.


AT - Automatic Transmission
Controls the car speed and the engine rpm. The inputs is the throttle applied to the car. The goal is to find an input throttle profile such that (a) the vehicle speed exceeds 120 km/h (b) the engine speed reaches 4500 rpm.


AFC - Power Train Benchmark
Controls the air-fuel flow within an engine and aims at maintaining the Air–fuel ratio close to a reference value. The inputs are the engine speed and the throttle angle. The goal is to find a test input profile for the throttle position showing that whenever event rise or fall happens,  the difference among the reference value of the Air–fuel ratio and the actual Air–fuel ratio exceeds a tolerable error.


IGC - Insulin Glucose Calibration
Controls the regulation of the concentration of glucose and insulin in the blood of a diabetic on day-to-day basis. The inputs are represented
by user actions that are not controllable by the insulin infusion pump such as, meal duration, start time, carbohydrates. The goal is to find a test input for the user actions that make the level of hypoglycemia exceeding a given threshold.
