# Portfolio

## Bachelorarbeit: Entwurf einer Fuzzy-Regelung für den rotatorischen Verteilteller einer Mehrkopfwaage

### &#8595; ***English version further down!*** &#8595;

Der Code meiner Bachelorarbeit kann in folgendem Repository eingesehen werden: [Repository](https://github.com/alexandernit/github-portfolio)

Meine Arbeit befasste sich mit der Verbesserung der Produktverteilung auf dem Verteilteller einer Mehrkopfwaage (siehe Abb.1) durch Implementierung zweier Fuzzy-Regler, die den gezielten Abwurf vom Verteilteller auf eine Dosierrinne ermöglichen. Das bestehende Modell wurde erweitert (*dynamics.m*), um die Dynamik eines Gleichstrommotors und die Rückkopplungseffekte von Partikeln zu berücksichtigen und zusätzlich wurde die Bewegung mehrerer Partikel (*multidynamics.m*) auf dem Verteilteller untersucht. Zwei Regelungskonzepte, ein Mamdani-Fuzzy-Regler (*mamdani2.fis*) und eine Takagi-Sugeno-Fuzzy-Regelung (*takagi1.fis*), wurden entwickelt.

| ![Waage](docs/ezgif.com-optimize.gif) |
| :--: |
| Abb.1.: Verwiegeprozess einer Mehrkopfwaage |
|*(Videoquelle: https://youtu.be/TVnA-7kJC74?si=OCO03Gl8Bz4dd9fg)* |


Durch Simulation (*fuzzySimulateWithConstInput.m*) über alle möglichen Abwurfpositionen konnten beide Fuzzy-Regler validiert werden. Beide Regler zeigten dabei sehr gute Ergebnisse (siehe Abb. 2), wobei grüne und gelbe Abwurfunkte für erfolgreiche Regelungssimulationen und rote nicht erfolgreich waren. Für die Regelung mehrerer Partikel wurde ein erster Simulationsversuch (*multiFuzzySimulateWithConstInput.m*) unternommen.

<img src="docs/mamdani.png" width="49%" height="50%">  <img src="docs/takagi.png" width="49%" height="50%"> 
Abb.2.: Ergebnisse Mamdani-Fuzzy-Regler (links) und Takagi-Fuzzy-Regler (rechts)

<br/><br/>
## Bachelor's Thesis: Design of a Fuzzy Controller for the Rotating Distribution Plate of a Multihead Weigher
The code for my bachelor's thesis can be found in the following repository: [Repository](https://github.com/alexandernit/github-portfolio)

My thesis focused on improving the product distribution on the distribution plate of a multihead weigher (see Fig. 1) by implementing two fuzzy controllers that enable precise product discharge from the plate onto a dosing chute. The existing model was extended (*dynamics.m*) to account for the dynamics of a DC motor and the feedback effects of particles. Additionally, the movement of multiple particles (*multidynamics.m*) on the distribution plate was examined. Two control concepts were developed: a Mamdani fuzzy controller (*mamdani2.fis*) and a Takagi-Sugeno fuzzy controller (*takagi1.fis*).

| ![Waage](docs/ezgif.com-optimize.gif) |
| :--: |
| Fig.1.: Weighing process of a multihead weigher |
|*(Video Source: https://youtu.be/TVnA-7kJC74?si=OCO03Gl8Bz4dd9fg)* |

Through simulations (*fuzzySimulateWithConstInput.m*) across all possible discharge positions, both fuzzy controllers were validated. Both controllers showed very good results (see Fig. 2), with green and yellow discharge points indicating successful control simulations and red indicating unsuccessful ones. An initial simulation attempt (*multiFuzzySimulateWithConstInput.m*) was also made for controlling multiple particles.

<img src="docs/mamdani.png" width="49%" height="50%">  <img src="docs/takagi.png" width="49%" height="50%"> 
Fig.2.: Results for Mamdani fuzzy controller (left) and Takagi-Sugeno fuzzy controller (right)
