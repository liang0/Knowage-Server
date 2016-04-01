angular.module('scorecardManager').controller('scorecardTargetDefinitionController', [ '$scope','sbiModule_translate' ,'sbiModule_restServices','sbiModule_config','$filter','$mdDialog','$mdToast','scorecardManager_targetUtility','scorecardManager_semaphoreUtility',scorecardTargetDefinitionControllerFunction ]);

function scorecardTargetDefinitionControllerFunction($scope,sbiModule_translate,sbiModule_restServices,sbiModule_config,$filter,$mdDialog,$mdToast,scorecardManager_targetUtility,scorecardManager_semaphoreUtility){
	$scope.kpiList=[];
	$scope.targetListAction =  [
		           {
			              label : 'Modify',
			              icon:'fa fa-pencil' , 
			              backgroundColor:'#ffcccc',
			              action : function(item,event) {
			            	  
			              }
			           },
			           {
				              label : 'Remove',
				              icon:'fa fa-times' , 
				              backgroundColor:'#ffcccc',
				              action : function(item,event) {
				            	  pos = 0;
				            	  while ($scope.currentTarget.kpis[pos].name != item.name)
				            		  pos++;
				            	  $scope.currentTarget.kpis.splice(pos,1);
				              }
				           }
					];
	
	$scope.parseDate = function(date){
		result = "";
		if(date == "d/m/Y"){
			result = "dd/MM/yyyy";
		}
		if(date =="m/d/Y"){
			result = "MM/dd/yyyy"
		}
		return result;
	};
	
	$scope.getListKPI = function(){
		sbiModule_restServices.promiseGet("1.0/kpi","listKpi")
		.then(function(response){ 
			for(var i=0;i<response.data.length;i++){
				var obj = angular.extend({},response.data[i]);
				var dateFormat = $scope.parseDate(sbiModule_config.localizedDateFormat);
				//parse date based on language selected
				obj["datacreation"]=$filter('date')(response.data[i].dateCreation, dateFormat);
				$scope.kpiList.push(obj);
			}
		},function(response){
			sbiModule_restServices.errorhandler(response.data,"");
		});
	};
	$scope.getListKPI();
	
	$scope.addKpiToTarget=function(){ 
		var tmpTargetKpis=[];
		if($scope.currentTarget.kpis==undefined){
			$scope.currentTarget.kpis = [];
		} 
		
		angular.copy($scope.currentTarget.kpis,tmpTargetKpis); 
		$mdDialog.show({
			controller: DialogControllerKPI,
			templateUrl: 'templatesaveKPI.html',
			clickOutsideToClose:false,
			preserveScope:true,
			locals: {
				kpiList: $scope.kpiList,
				tmpTargetKpis: tmpTargetKpis}
		})
		.then(function(data) {
		console.log(data)
		angular.copy(data,$scope.currentTarget.kpis);
		});
		
	};

	var DialogControllerKPI= function($scope,kpiList,tmpTargetKpis){
		$scope.kpiAllList=kpiList;
		$scope.kpiSelected=tmpTargetKpis;
		
		$scope.saveKpiToTarget=function(){
			  $mdDialog.hide($scope.kpiSelected);
		}
		$scope.close=function(){
			$mdDialog.cancel();
		}
	}
		
	$scope.addGroupedKpisItem=function(type){
		for(var i=0;i<$scope.currentTarget.groupedKpis.length;i++){
			if(angular.equals($scope.currentTarget.groupedKpis[i].status,type)){
				findedStatus=$scope.currentTarget.groupedKpis[i].count++;
				return;
			}
		}
		 $scope.currentTarget.groupedKpis.push({status:type,count:1});
	}
	 
	
	$scope.loadGroupedKpis=function(){
		for(var i=0;i<$scope.currentTarget.kpis.length;i++){
			$scope.addGroupedKpisItem(scorecardManager_semaphoreUtility.typeColor[Math.floor(Math.random() * 4)]);
		}
		$scope.currentTarget.status=scorecardManager_targetUtility.getTargetStatus($scope.currentTarget);
		}
	
	$scope.$on('saveTarget', function(event, args) {
		if($scope.currentTarget.name.trim()==""){
			 $mdToast.show(
				      $mdToast.simple()
				        .content('Name is required')
				        .position("TOP")
				        .hideDelay(3000)
				    );
			 return;
		}
		if($scope.currentTarget.kpis==undefined || $scope.currentTarget.kpis.length==0){
			 $mdToast.show(
				      $mdToast.simple()
				        .content('Select at least one kpi ')
				        .position("TOP")
				        .hideDelay(3000)
				    );
			 return;
		}
		
		$scope.loadGroupedKpis();
		
		$scope.currentPerspective.targets.push(angular.extend({},$scope.currentTarget));
		angular.copy($scope.emptyTarget,$scope.currentTarget);
		$scope.stepControl.prevBread();
 	});
	
	$scope.$on('cancelTarget', function(event, args) {
		if(!angular.equals($scope.emptyTarget,$scope.currentTarget)){
	 		var confirm = $mdDialog.confirm()
	        .title(sbiModule_translate.load("sbi.layer.modify.progress"))
	        .content(sbiModule_translate.load("sbi.layer.modify.progress.message.modify"))
	        .ariaLabel('cancel targetr') 
			.ok(sbiModule_translate.load("sbi.general.yes"))
			.cancel(sbiModule_translate.load("sbi.general.No"));
			  $mdDialog.show(confirm).then(function() {
					$scope.stepControl.prevBread();
			  }, function() {
			   return;
			  });
 		}else{
 			$scope.stepControl.prevBread();
 		} 
 	});
	
}