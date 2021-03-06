% Copyright @2015 MIT License - Author - Harshal Priyadarshi - IIT Roorkee
% See the License document for further information
clc;
% Game Simulation for TD-Gammon
%% load the learnt parameters after 16k iterations
load('bestUser16kIteration.mat');

%% initiate the boolean winner index = 0 (computer won) = 1 (user won) = 2 (no info)
whoWon = 2;


%% throw in dice to decide whose move
areDiesSame = true;
while(areDiesSame == true)
    agentProxyDie = randi(6,[1,1]);
    userProxyDie = str2double(input('Enter the value of your die, Please.[1 to 6]: ','s'));
    if(agentProxyDie ~= userProxyDie)
        areDiesSame = false;
        if(agentProxyDie > userProxyDie)
            userChance = 0;
        else
            userChance = 1;
        end
    end
end

%% start initial board
boardPresent = generateInitialBoard(userChance);
boardReadable = generateReadableBoard(boardPresent);
disp('Board Outlook at present:');
disp(boardReadable);
%% initial die
dice = [agentProxyDie, userProxyDie];
fprintf('It is chance of [0 = Computer, 1 = User] %d and dice Roll is [%d,%d]\n',userChance,dice(1),dice(2));
%% run a simulation till no result has been obtained
while(whoWon == 2)
     if(userChance == 0)
         boardRevertReadable = changeRoles(boardReadable);
         boardRevert = getNNfromReadableBoard(boardRevertReadable,1);
         favorability = TestRun( V_InHide, V_HideOut, boardRevertReadable, boardRevert, dice,1) % userChance = 1 as our Agent-2 was the best learner while training
         
         bestMoveTemp = favorability(1,2:end);
         bestMove = bestMoveTemp;
         for i = [1,3,5,7]
             if(bestMoveTemp(i + 1) ~= 0 || bestMoveTemp(i) ~= 0)
                 bestMove(i) = 25 - bestMoveTemp(i);
                 bestMove(i + 1) = 25 - bestMoveTemp(i + 1);
             end
             bestMove(bestMove == 26) = -1;
         end
         disp('Computers Move:');
         disp(bestMove);
         % update the NN,readable board and userChance
         boardPresent = generateBoardFromMove(bestMove,boardPresent,false);
         boardReadable = generateReadableBoard(boardPresent);
         disp('Board Outlook at present:');
         disp(boardReadable);
         userChance = ~userChance;
         fprintf('It is chance of [0 = Computer, 1 = User] %d\n', userChance);
     else
         correctMoveMade = false;
         while(correctMoveMade == false)
            userMove = str2num(input('Write Your move in vector format separated by commas, Please.(0 to surrender):', 's'));
            % in case the user surrenders his move - Enter 0 if wanna
            % surrender
            if(userMove == 0)
                boardPresent(193) = 1;
                boardPresent(194) = 0;
                userChance = ~userChance;
                fprintf('It is chance of [0 = Computer, 1 = User] %d \n', userChance);
                break;
            end
            % check if the move is right
            if(size(userMove,2) <= 8 && mod(size(userMove,2),2) == 0)
                userMove = horzcat(userMove,zeros(1,8 - size(userMove,2)));
                %%%%% temporary work around the -1 bug - PART 1
                userMove(userMove == -1) = 26;
                %%%%% bug section ends
                if(sum(userMove([1,3,5,7]) >= userMove([2,4,6,8])) == 4)
                    %%%%% temporary work around the -1 bug - PART 2
                    userMove(userMove == 26) = -1;
                    %%%%% bug section ends
                    favorability = TestRun( V_InHide, V_HideOut, boardReadable, boardPresent, dice,1)
                    [~,indx]=ismember(userMove,favorability(:,2:end),'rows');
                    if(indx ~= 0)
                        correctMoveMade = true;
                        disp('Yours Move:');
                        disp(userMove);
                        % update the NN, readable board and userChance
                        boardPresent = generateBoardFromMove(userMove,boardPresent,false);
                        boardReadable = generateReadableBoard(boardPresent);
                        disp('Board Outlook at present:');
                        disp(boardReadable);
                        userChance = ~userChance;
                        fprintf('It is chance of [0 = Computer, 1 = User] %d\n', userChance);
                    end
                end
            end
         end
     end
     
     % check if game has ended
     if(boardReadable(2,2) == 15)
         whoWon = 1; % user won
         fprintf('User Won');
     elseif(boardReadable(1,27) == 15)
         whoWon = 0; % agent won
         fprintf('Agent Won');
     else  % repeat with a new die
         equalDiceAllowed = 6;
         dice = randi(6,[1,2]);
         if(dice(1) == dice(2))
             while(equalDiceAllowed > 0)
                 dice = randi(6,[1,2]);
                 if(dice(1) ~= dice(2))
                     break;
                 else
                     equalDiceAllowed = equalDiceAllowed - 1;
                 end
             end
         end
         if(dice(1) == dice(2))
            dice = [dice,dice];
         end
         disp('Dice Throw:');
         disp(dice);
     end
     
     
         
end
