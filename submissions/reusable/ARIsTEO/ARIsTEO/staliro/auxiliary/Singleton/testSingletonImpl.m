% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
%% Test Script for Class SingletonImpl
% Step through and execute this script cell-by-cell to verify the Singleton
% Desgin Pattern implementation in MATLAB. 
%
% Written by Bobby Nedelkovski
% The MathWorks Australia Pty Ltd
% Copyright 2009, The MathWorks, Inc.


%% Clean Up
clear classes
clc


%% Try Create Instance with Constructor
% This yields an error as expected since we are guarding the constructor
% from user access.
a = SingletonImpl();


%% Create Instance 'a' Using instance() Method
a = SingletonImpl.instance()


%% Check Protected Property
% This yields an error as singletonData is private to the abstract class
% Singleton.
a.singletonData


%% Query Protected Property
data = a.getSingletonData()


%% Modify Protected Property
a.setSingletonData(0);


%% Query Protected Property
% Verify that singletonData has changed -> singletonData = 0.
data = a.getSingletonData()


%% Use Custom Method
% This method internally modifies singletonData. 
a.myOperation(9);


%% Check Custom Method
% Check that singletonData has changed -> singletonData = 9.
data = a.getSingletonData()


%% Modify Custom Attribute Using 'a'
a.myData = 1


%% Create Another Reference 'b' to the Same Singleton
% Notice that 'a' and 'b' refer to the same object in memory ->
% singletonData = 1 for both.
b = SingletonImpl.instance()


%% Modify Custom Attribute Using 'b'
% Both 'a' and 'b' reflect the change in value.
b.myData = 3;
a
b

%% Clear Variable 'a' From Workspace
clear a
b


%% Create Another Reference 'c' to the Same Singleton
% Notice that 'b' and 'c' refer to the same object in memory ->
% myData = 3 for both
c = SingletonImpl.instance()


%% Modify Custom Attribute Using 'c'
% Both 'b' and 'c' reflect the change in value.
c.myData = 5;
b
c


%% Clear Variables
% No variables 
clear b c data


%% Create Another Reference 'd' to the Same Singleton
% Notice that 'd' refers to the same object in memory as did 'a', 'b' and
% 'c' earlier -> myData = 5 
d = SingletonImpl.instance()


%% Destroy Singleton in Memory
clear all


%% Create New Instance 'e'
% The myData property is empty.
e = SingletonImpl.instance()

