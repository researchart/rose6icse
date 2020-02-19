## Prerequisite
- Matlab R2018a
- Matlab System Identification Toolbox

## Installation instructions
- open the folder ARIsTEO with Matlab
- add the folder ARIsTEO and all of its subfolders on your classpath (right click on the folder > add to path > selected folder and subfolders)
- open the folder ``staliro``
- run the command ``setup_staliro``

For a description of the parameters and the Usage of ARIsTEO type "help aristeo"  

## Basic Usage -- The Pendulum Example

The pendulum is the simplest mechanical system you can model. This system contains two bodies, a link and a fixed pivot, connected by a revolute joint.

The input it the applied moment at every time instant (continuous signal representing the momentun applied to the pendulum at different time instants -- See figure on the left)

<img src="./Satisfaction.png" alt="ARIsTEO logo" width="96"><img src="./Violation.png" alt="ARIsTEO logo" width="96">

The property of interest states that the pendulum should remain below the horizontal line that crosses the fixed pivot. When the pendulum goes above the horizontal line the color of the pendulum changes from green to red. <br/>

The goal of the testing activity is to search for a test input that violates this property.


By running the following commands a pendulum will be shown on the screen. Different simulations are performed where ARIsTEO searches for a a test input that violates the property. When a test input that violates the property is found  the pendulum changes its color from green to red, meaning that the property is violated and the test case generation stops.

``% Defines a variable that contains the name of the model``<br/>
``model='simppend';``<br/>

``% Considers the default initial conditions of the model``<br/>
``init_cond = [];``<br/>

``% Sets the input_range. We assume that the user can apply a momentun in the range [-0.5 0.5]``<br/>
``input_range = [-2 2];``<br/>

``% Sets the number of control points. We assume the inputs has 100 control points``<br/>
``cp_array = 100;``

``% Defines of the property of interest. The pendulum must remain below the horizontal line. The ARIsTEO testing framework searches for a test input that showing that the pendulum does not remain below the horizontal line. ``<br/>
``phi='[]_[0,10000] (a/\b)';``<br/>
``preds(1).str = 'a';``<br/>
``preds(1).A = [1];``<br/>
``preds(1).b = [1.5];``<br/>
``preds(2).str = 'b';``<br/>
``preds(2).A = [-1];``<br/>
``preds(2).b = [1.5];``<br/>

``% Sets the simulation Time``<br/>
``TotSimTime=10;``<br/>

``% Creates the options of ARIsTEO``<br/>
``opt=aristeo_options();``<br/>

``% Sets the number of refinements rounds``<br/>
``opt.n_refinement_rounds=20;``<br/>

``%Sets the abstraction algorithm and its parameters``<br/>
``opt.fals_at_zero=0;``<br/>
``opt.abstraction_algorithm='ss';``<br/>
``opt.nx=2;``<br/>
``opt.optim_params.n_tests=10;``<br/>
``opt.dispinfo=1;``<br/>

``% Runs ARIsTEO``<br/>
``[resultsaristeo,inputaristeo] = aristeo(model, init_cond, input_range, cp_array, phi, preds, TotSimTime, opt);``<br/>

A pendulum will be shown on the screen. Different simulations are performed where ARIsTEO searches for a a test input (continuous signal representing the momentun applied to the pendulum at different time instants) that showing that the pendulum does not remain below the horizontal line. When the pendulum goes above the horizontal line the color of the pendulum changes from green to red, meaning that the property is violated and the simulation stops.<br/>

Note that, since the algorithm is based on search based testing (in some cases) it can happen that no violation of the property is detected. The user can repeat the experiment of increase the number of refinement rounds to increase the accuracy of ARIsTEO.
